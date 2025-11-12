import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/product.dart';
import '../utils/geo_utils.dart';

class LedSitesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Find LED billboard sites along a route
  Future<List<Map<String, dynamic>>> findSitesAlongRoute({
    required List<LatLng> routePoints,
    LatLngBounds? routeBounds,
    double radiusMeters = 500,
    int maxResults = 100,
    int firestoreQueryLimit = 500,
  }) async {
    // Validate inputs
    if (routePoints.isEmpty) {
      return [];
    }

    try {
      // Get all active products (client-side filtering due to nested geopoint structure)
      final allProducts = await getAllActiveProducts(limit: 1000);

      // Filter products by distance to route
      return _filterProductsByRouteDistance(
        allProducts,
        routePoints,
        radiusMeters,
        maxResults,
      );
    } catch (e) {
      // Return empty list on error rather than crashing
      return [];
    }
  }

  /// Find all LED billboard sites along a route (queries all products, filters client-side)
  Future<List<Map<String, dynamic>>> findAllSitesAlongRoute({
    required List<LatLng> routePoints,
    double radiusMeters = 500,
    int maxResults = 100,
  }) async {
    // Validate inputs
    if (routePoints.isEmpty) {
      return [];
    }

    try {
      // Get all active products
      final allProducts = await getAllActiveProducts(limit: 1000);

      // Filter products by distance to route
      return _filterProductsByRouteDistance(
        allProducts,
        routePoints,
        radiusMeters,
        maxResults,
      );
    } catch (e) {
      // Return empty list on error rather than crashing
      return [];
    }
  }

  /// Query products within bounding box
  Future<QuerySnapshot> _queryProductsInBounds(LatLngBounds bounds, int limit) async {
    return await _firestore
        .collection('products')
        .where('active', isEqualTo: true)
        .where('content_type', isEqualTo: 'digital')
        .where('geopoint.latitude', isGreaterThanOrEqualTo: bounds.southwest.latitude)
        .where('geopoint.latitude', isLessThanOrEqualTo: bounds.northeast.latitude)
        .limit(limit)
        .get();
  }

  /// Alternative query method for Firestore arrays (if geopoint is stored as array)
  Future<QuerySnapshot> _queryProductsInBoundsArray(LatLngBounds bounds, int limit) async {
    // Note: Firestore doesn't support direct bounding box queries on array fields
    // This would require a different approach or composite indexes
    // For now, we'll use a broader query and filter client-side
    return await _firestore
        .collection('products')
        .where('active', isEqualTo: true)
        .where('content_type', isEqualTo: 'digital')
        .limit(limit)
        .get();
  }

  /// Get all active products (fallback method)
  Future<List<Product>> getAllActiveProducts({int limit = 1000}) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('active', isEqualTo: true)
          .where('content_type', isEqualTo: 'digital')
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Additional client-side filter to ensure content_type == 'digital'
            if (data['content_type'] == 'digital') {
              try {
                return Product.fromFirestore(doc);
              } catch (e) {
                return null;
              }
            }
            return null;
          })
          .where((product) => product != null)
          .cast<Product>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Filter products by distance to route (client-side filtering)
  List<Map<String, dynamic>> _filterProductsByRouteDistance(
    List<Product> products,
    List<LatLng> routePoints,
    double radiusMeters,
    int maxResults,
  ) {
    final nearbySites = <Map<String, dynamic>>[];

    for (final product in products) {
      // Skip invalid geopoints
      if (product.position.latitude == 0 && product.position.longitude == 0) {
        continue;
      }

      final distanceMeters = GeoUtils.pointToPolylineDistance(product.position, routePoints);

      if (distanceMeters <= radiusMeters) {
        nearbySites.add({
          'markerId': product.siteCode.isNotEmpty ? product.siteCode : product.id,
          'position': {
            'lat': product.position.latitude,
            'lng': product.position.longitude,
          },
          'infoWindowTitle': product.name,
          'infoWindowSnippet': product.markerSnippet,
          'price': product.price,
          'distanceMeters': distanceMeters,
          'rawProduct': product.rawData,
        });
      }
    }

    // Sort by distance and limit
    nearbySites.sort((a, b) => (a['distanceMeters'] as double).compareTo(b['distanceMeters'] as double));
    return nearbySites.take(maxResults).toList();
  }

  /// Find LED billboard sites near specified places
  Future<List<Map<String, dynamic>>> findSitesNearPlaces({
    required List<LatLng> places,
    double radiusMeters = 1000,
    int maxResults = 50,
  }) async {
    // Validate inputs
    if (places.isEmpty) {
      return [];
    }

    try {
      // Get all active products
      final allProducts = await getAllActiveProducts(limit: 1000);

      // Filter products by distance to any of the places
      final nearbySites = <String, Map<String, dynamic>>{};
      final addedProductIds = <String>{};

      for (final product in allProducts) {
        // Skip invalid geopoints
        if (product.position.latitude == 0 && product.position.longitude == 0) {
          continue;
        }

        for (final place in places) {
          final distanceMeters = GeoUtils.haversineDistance(product.position, place);

          if (distanceMeters <= radiusMeters && !addedProductIds.contains(product.id)) {
            nearbySites[product.id] = {
              'markerId': product.siteCode.isNotEmpty ? product.siteCode : product.id,
              'position': {
                'lat': product.position.latitude,
                'lng': product.position.longitude,
              },
              'infoWindowTitle': product.name,
              'infoWindowSnippet': product.markerSnippet,
              'price': product.price,
              'distanceMeters': distanceMeters,
              'rawProduct': product.rawData,
            };
            addedProductIds.add(product.id);
            break; // Add each product only once
          }
        }
      }

      final sitesList = nearbySites.values.toList();

      // Sort by distance and limit results
      sitesList.sort((a, b) => (a['distanceMeters'] as double).compareTo(b['distanceMeters'] as double));

      return sitesList.take(maxResults).toList();
    } catch (e) {
      // Return empty list on error rather than crashing
      return [];
    }
  }
}