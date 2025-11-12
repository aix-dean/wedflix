import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;
  final String type;
  final String? photoUrl;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.type,
    this.photoUrl,
  });

  String? getPhotoUrl(String apiKey) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoUrl&key=$apiKey';
    }
    return null;
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final location = geometry['location'];

    // Parse photos
    String? photoReference;
    if (json['photos'] != null && json['photos'] is List && json['photos'].isNotEmpty) {
      photoReference = json['photos'][0]['photo_reference'];
    }

    return Place(
      id: json['place_id'],
      name: json['name'],
      lat: location['lat'],
      lng: location['lng'],
      address: json['vicinity'] ?? '',
      type: json['types']?.first ?? 'unknown',
      photoUrl: photoReference,
    );
  }
}

class PlacesService {
  final String apiKey = 'AIzaSyA2ZYkuSy0TU-5NYthX6RTL_XyCJlWn6oI'; // Using provided API key

  // Decode Google Maps encoded polyline
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination, {List<LatLng>? waypoints}) async {
    String waypointsParam = '';
    if (waypoints != null && waypoints.isNotEmpty) {
      waypointsParam = '&waypoints=' + waypoints.map((wp) => '${wp.latitude},${wp.longitude}').join('|');
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      '$waypointsParam&'
      'mode=driving&'
      'key=$apiKey'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final route = routes[0];
          final legs = route['legs'] as List;

          // Collect all polyline points from steps for more detailed route
          List<LatLng> allPoints = [];
          for (final leg in legs) {
            final steps = leg['steps'] as List;
            for (final step in steps) {
              final polyline = step['polyline']['points'];
              allPoints.addAll(decodePolyline(polyline));
            }
          }

          // If no step polylines (unlikely), fall back to overview
          if (allPoints.isEmpty) {
            final overviewPolyline = route['overview_polyline']['points'];
            allPoints = decodePolyline(overviewPolyline);
          }

          return allPoints;
        } else {
          throw Exception('No routes found');
        }
      } else {
        throw Exception('Directions API error: ${data['status']}');
      }
    } else {
      throw Exception('Failed to fetch directions: ${response.statusCode}');
    }
  }

  Future<List<Place>> getNearbyPlaces(double lat, double lng) async {
    List<Place> allPlaces = [];

    // Fetch hotels (lodging)
    final hotels = await _fetchPlaces(lat, lng, 'lodging');
    allPlaces.addAll(hotels.map((p) => Place(
      id: p.id,
      name: p.name,
      lat: p.lat,
      lng: p.lng,
      address: p.address,
      type: 'hotel',
      photoUrl: p.photoUrl,
    )));

    // Fetch churches
    final churches = await _fetchPlaces(lat, lng, 'church');
    allPlaces.addAll(churches.map((p) => Place(
      id: p.id,
      name: p.name,
      lat: p.lat,
      lng: p.lng,
      address: p.address,
      type: 'church',
      photoUrl: p.photoUrl,
    )));

    // Fetch reception venues (establishment with keyword)
    final receptions = await _fetchPlaces(lat, lng, 'establishment', keyword: 'wedding OR banquet OR event hall');
    allPlaces.addAll(receptions.map((p) => Place(
      id: p.id,
      name: p.name,
      lat: p.lat,
      lng: p.lng,
      address: p.address,
      type: 'reception',
      photoUrl: p.photoUrl,
    )));

    return allPlaces;
  }

  Future<List<Place>> _fetchPlaces(double lat, double lng, String type, {String? keyword}) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
      'location=$lat,$lng&radius=50000&type=$type${keyword != null ? '&keyword=$keyword' : ''}&key=$apiKey'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final results = data['results'] as List;
        return results.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Places API error: ${data['status']}');
      }
    } else {
      throw Exception('Failed to fetch places: ${response.statusCode}');
    }
  }
}