import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoUtils {
  // Earth's radius in meters
  static const double _earthRadius = 6371000;

  /// Calculate Haversine distance between two points in meters
  static double haversineDistance(LatLng point1, LatLng point2) {
    final lat1Rad = _degreesToRadians(point1.latitude);
    final lat2Rad = _degreesToRadians(point2.latitude);
    final deltaLatRad = _degreesToRadians(point2.latitude - point1.latitude);
    final deltaLngRad = _degreesToRadians(point2.longitude - point1.longitude);

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadius * c;
  }

  /// Calculate minimum distance from a point to a polyline (route) in meters
  static double pointToPolylineDistance(LatLng point, List<LatLng> polyline) {
    if (polyline.isEmpty) return double.infinity;
    if (polyline.length == 1) return haversineDistance(point, polyline[0]);

    double minDistance = double.infinity;

    // Check distance to each segment
    for (int i = 0; i < polyline.length - 1; i++) {
      final distance = _pointToSegmentDistance(point, polyline[i], polyline[i + 1]);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance;
  }

  /// Calculate distance from a point to a line segment
  static double _pointToSegmentDistance(LatLng point, LatLng segmentStart, LatLng segmentEnd) {
    final A = point.latitude - segmentStart.latitude;
    final B = point.longitude - segmentStart.longitude;
    final C = segmentEnd.latitude - segmentStart.latitude;
    final D = segmentEnd.longitude - segmentStart.longitude;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;

    if (lenSq == 0) {
      // Segment is a point
      return haversineDistance(point, segmentStart);
    }

    final param = dot / lenSq;

    LatLng closestPoint;
    if (param < 0) {
      closestPoint = segmentStart;
    } else if (param > 1) {
      closestPoint = segmentEnd;
    } else {
      // Projection falls on the segment
      closestPoint = LatLng(
        segmentStart.latitude + param * C,
        segmentStart.longitude + param * D,
      );
    }

    return haversineDistance(point, closestPoint);
  }

  /// Calculate bounding box for a list of LatLng points
  static LatLngBounds calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      // Return a default bounds around Manila
      return LatLngBounds(
        southwest: const LatLng(14.5995, 120.9842),
        northeast: const LatLng(14.5995, 120.9842),
      );
    }

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (final point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Expand bounding box by a radius in meters
  static LatLngBounds expandBounds(LatLngBounds bounds, double radiusMeters) {
    // Approximate degrees per meter (rough estimate)
    const double metersPerDegreeLat = 111320; // at equator
    const double metersPerDegreeLng = 111320; // at equator (will be adjusted by latitude)

    final latExpansion = radiusMeters / metersPerDegreeLat;
    final avgLat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final lngExpansion = radiusMeters / (metersPerDegreeLng * cos(_degreesToRadians(avgLat)));

    return LatLngBounds(
      southwest: LatLng(
        bounds.southwest.latitude - latExpansion,
        bounds.southwest.longitude - lngExpansion,
      ),
      northeast: LatLng(
        bounds.northeast.latitude + latExpansion,
        bounds.northeast.longitude + lngExpansion,
      ),
    );
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Check if a point is within a bounding box
  static bool isPointInBounds(LatLng point, LatLngBounds bounds) {
    return point.latitude >= bounds.southwest.latitude &&
           point.latitude <= bounds.northeast.latitude &&
           point.longitude >= bounds.southwest.longitude &&
           point.longitude <= bounds.northeast.longitude;
  }

  /// Sample points along a polyline at regular intervals (in meters)
  static List<LatLng> samplePointsAlongPolyline(List<LatLng> polyline, double intervalMeters) {
    if (polyline.isEmpty) return [];
    if (polyline.length == 1) return [polyline[0]];

    final sampledPoints = <LatLng>[];
    sampledPoints.add(polyline[0]); // Always include the starting point

    double accumulatedDistance = 0.0;

    for (int i = 0; i < polyline.length - 1; i++) {
      final start = polyline[i];
      final end = polyline[i + 1];
      final segmentDistance = haversineDistance(start, end);

      if (accumulatedDistance + segmentDistance >= intervalMeters) {
        // Calculate how much distance we need to cover in this segment
        double remainingDistance = intervalMeters - accumulatedDistance;

        while (remainingDistance <= segmentDistance) {
          // Interpolate point along the segment
          final ratio = remainingDistance / segmentDistance;
          final interpolatedPoint = LatLng(
            start.latitude + ratio * (end.latitude - start.latitude),
            start.longitude + ratio * (end.longitude - start.longitude),
          );
          sampledPoints.add(interpolatedPoint);

          remainingDistance += intervalMeters;
        }
        accumulatedDistance = segmentDistance - (remainingDistance - intervalMeters);
      } else {
        accumulatedDistance += segmentDistance;
      }
    }

    // Ensure we don't have duplicates at the end
    if (sampledPoints.isNotEmpty && polyline.last != sampledPoints.last) {
      sampledPoints.add(polyline.last);
    }

    return sampledPoints;
  }
}