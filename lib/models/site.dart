import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Review {
  final String reviewerName;
  final String reviewText;
  final double rating;
  final String timeAgo;

  Review({
    required this.reviewerName,
    required this.reviewText,
    required this.rating,
    required this.timeAgo,
  });
}

class Feature {
  final String title;
  final String description;
  final IconData icon;

  Feature({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class Site {
  final String id;
  final String name;
  final List<String> imageUrls; // For carousel
  final double price;
  final LatLng position;
  final String location;
  final String description;
  final String siteCode;
  final String size;
  final double rating;
  final int reviewCount;
  final List<Review> reviews;
  final List<Feature> features;
  final double distanceMeters;
  final Map<String, dynamic>? rawData;

  Site({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.price,
    required this.position,
    required this.location,
    required this.description,
    required this.siteCode,
    required this.size,
    required this.rating,
    required this.distanceMeters,
    this.reviewCount = 0,
    this.reviews = const [],
    this.features = const [],
    this.rawData,
  });

  // Backward compatibility getter
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls[0] : 'https://via.placeholder.com/310x310?text=${name}';

  factory Site.fromLedSiteData(Map<String, dynamic> data) {
    final rawProduct = data['rawProduct'] as Map<String, dynamic>?;
    final imageUrl = _getImageUrl(data);
    return Site(
      id: data['markerId'] ?? '',
      name: data['infoWindowTitle'] ?? '',
      imageUrls: [imageUrl], // Wrap single image in list
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      position: LatLng(
        data['position']['lat'] ?? 0.0,
        data['position']['lng'] ?? 0.0,
      ),
      location: _extractLocation(data['infoWindowSnippet'] ?? ''),
      description: rawProduct?['description'] ?? '',
      siteCode: data['markerId'] ?? '',
      distanceMeters: (data['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      size: rawProduct?['size'] ?? 'Unknown size',
      rating: (rawProduct?['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: 0, // Default, can be updated later
      reviews: [], // Default, can be updated later
      features: [
        Feature(
          title: 'Fast confirmation',
          description: 'Booking confirmation in 48 hours',
          icon: Icons.access_time,
        ),
        Feature(
          title: 'Bright colors',
          description: 'Equipped with latest LED models',
          icon: Icons.lightbulb,
        ),
        Feature(
          title: 'Free cancellation',
          description: 'Before Apr 1, 2026',
          icon: Icons.cancel,
        ),
      ], // Default features
      rawData: rawProduct,
    );
  }

  static String _getImageUrl(Map<String, dynamic> data) {
    final rawProduct = data['rawProduct'];
    if (rawProduct != null) {
      // Check for media array first
      final media = rawProduct['media'];
      if (media is List && media.isNotEmpty) {
        final firstMedia = media[0];
        if (firstMedia is Map && firstMedia['url'] != null) {
          return firstMedia['url'];
        }
      }
      // Fallback to photoUrl if exists
      if (rawProduct['photoUrl'] != null) {
        return rawProduct['photoUrl'];
      }
    }
    // Fallback to placeholder
    return 'https://via.placeholder.com/310x310?text=${data['infoWindowTitle'] ?? 'Site'}';
  }

  static String _extractLocation(String snippet) {
    final parts = snippet.split(' · ');
    return parts.length > 1 ? parts[1] : '';
  }

  String get formattedPrice {
    return '₱${price.toStringAsFixed(2)}';
  }

  String get displaySnippet {
    return '$formattedPrice · $location';
  }
}