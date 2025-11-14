import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final LatLng position;
  final String location;
  final String description;
  final String siteCode;
  final List<String> categoryNames;
  final bool active;
  final String? sellerId;
  final Map<String, dynamic>? rawData;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.position,
    required this.location,
    required this.description,
    required this.siteCode,
    required this.categoryNames,
    required this.active,
    this.sellerId,
    this.rawData,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final specsRental = data['specs_rental'] as Map<String, dynamic>?;

    // Parse geopoint - handle nested structure in specs_rental or root level
    late LatLng position;

    // Try specs_rental.geopoint first (new structure)
    if (specsRental?['geopoint'] is GeoPoint) {
      final geoPoint = specsRental!['geopoint'] as GeoPoint;
      position = LatLng(geoPoint.latitude, geoPoint.longitude);
    }
    // Fallback to root geopoint (old structure)
    else if (data['geopoint'] is GeoPoint) {
      final geoPoint = data['geopoint'] as GeoPoint;
      position = LatLng(geoPoint.latitude, geoPoint.longitude);
    }
    // Handle array format [lat, lng]
    else if (data['geopoint'] is List && data['geopoint'].length >= 2) {
      position = LatLng(
        (data['geopoint'][0] as num).toDouble(),
        (data['geopoint'][1] as num).toDouble(),
      );
    } else {
      // Skip invalid geopoints
      throw Exception('Invalid geopoint data for product ${doc.id}');
    }

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      position: position,
      location: data['location'] ?? specsRental?['location'] ?? '',
      description: data['description'] ?? '',
      siteCode: data['site_code'] ?? specsRental?['site_code'] ?? '',
      categoryNames: List<String>.from(data['categories'] ?? []),
      active: data['active'] ?? false,
      sellerId: data['seller_id'],
      rawData: data,
    );
  }

  // Format price with Philippine Peso symbol
  String get formattedPrice {
    String numberStr = price >= 1000 ? NumberFormat('#,###.##').format(price) : price.toStringAsFixed(2);
    return '₱$numberStr / Day';
  }

  // Create marker info snippet
  String get markerSnippet {
    return '$formattedPrice · $location';
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, location: $location)';
  }
}