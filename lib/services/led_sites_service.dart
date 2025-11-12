import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:algolia_client_search/algolia_client_search.dart' show SearchClient, SearchParamsObject, IndexClient;
import '../models/product.dart';
import '../utils/geo_utils.dart';

class LedSitesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SearchClient _algoliaClient = SearchClient(
    appId: 'DHRR76C4T7',
    apiKey: '33b65c315b7fa94af6b8db4364c14386',
  );

  /// Find LED billboard sites along a route
  Future<List<Map<String, dynamic>>> findSitesAlongRoute({
    required List<LatLng> routePoints,
    LatLngBounds? routeBounds,
    double radiusMeters = 1000,
    int maxResults = 50,
    int firestoreQueryLimit = 500,
  }) async {
    // Validate inputs
    if (routePoints.isEmpty) {
      return [];
    }

    try {
      // Sample route points every 500 meters
      final sampledPoints = GeoUtils.samplePointsAlongPolyline(routePoints, 500.0);

      // Perform Algolia geo-searches for each sampled point
      final allResults = <String, Map<String, dynamic>>{};
      final seenIds = <String>{};

      for (final point in sampledPoints) {
        final results = await _searchNearbySites(point, radiusMeters);
        for (final result in results) {
          final id = result['objectID'] as String?;
          if (id != null && !seenIds.contains(id)) {
            seenIds.add(id);
            allResults[id] = result;
          }
        }
      }

      // Convert to list, sort by distance, and limit
      final sitesList = allResults.values.toList();
      sitesList.sort((a, b) => (a['distanceMeters'] as double).compareTo(b['distanceMeters'] as double));
      return sitesList.take(maxResults).toList();
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
      // Perform Algolia geo-searches for each place
      final allResults = <String, Map<String, dynamic>>{};
      final seenIds = <String>{};

      for (final place in places) {
        final results = await _searchNearbySites(place, radiusMeters);
        for (final result in results) {
          final id = result['objectID'] as String?;
          if (id != null && !seenIds.contains(id)) {
            seenIds.add(id);
            allResults[id] = result;
          }
        }
      }

      // Convert to list, sort by distance, and limit
      final sitesList = allResults.values.toList();
      sitesList.sort((a, b) => (a['distanceMeters'] as double).compareTo(b['distanceMeters'] as double));
      return sitesList.take(maxResults).toList();
    } catch (e) {
      // Return empty list on error rather than crashing
      return [];
    }
  }
  /// Search for sites near a specific point using Algolia
  Future<List<Map<String, dynamic>>> _searchNearbySites(LatLng point, double radiusMeters) async {
    try {
      final index = IndexClient(_algoliaClient, 'products');
      final response = await index.search(
        SearchParamsObject(
          query: '',
          aroundLatLng: '${point.latitude}, ${point.longitude}',
          aroundRadius: radiusMeters.toInt(),
          hitsPerPage: 50,
        ),
      );

      return response.hits.map((hit) {
        final data = hit.data;
        final geoloc = data['_geoloc'];
        double lat = 0.0;
        double lng = 0.0;
        if (geoloc is Map) {
          lat = (geoloc['lat'] as num?)?.toDouble() ?? 0.0;
          lng = (geoloc['lng'] as num?)?.toDouble() ?? 0.0;
        } else if (geoloc is List && geoloc.length >= 2) {
          lat = (geoloc[0] as num?)?.toDouble() ?? 0.0;
          lng = (geoloc[1] as num?)?.toDouble() ?? 0.0;
        }

        final distance = GeoUtils.haversineDistance(point, LatLng(lat, lng));

        return {
          'objectID': hit.objectID,
          'markerId': data['siteCode'] ?? hit.objectID ?? '',
          'position': {'lat': lat, 'lng': lng},
          'infoWindowTitle': data['name'] ?? '',
          'infoWindowSnippet': '₱${(data['price'] as num?)?.toDouble() ?? 0.0}',
          'price': (data['price'] as num?)?.toDouble() ?? 0.0,
          'distanceMeters': distance,
          'rawProduct': data,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}