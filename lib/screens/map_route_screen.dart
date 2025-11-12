import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/places_service.dart';
import '../services/led_sites_service.dart';
import '../models/site.dart';

class LedSiteMapScreen extends StatefulWidget {
  const LedSiteMapScreen({super.key});

  @override
  State<LedSiteMapScreen> createState() => _LedSiteMapScreenState();
}

class _LedSiteMapScreenState extends State<LedSiteMapScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool isLoadingRoutes = true;
  bool _isDisposed = false;
  List<Site> ledSites = [];
  BitmapDescriptor? ledIcon;
  LatLngBounds? cameraBounds;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    _setupMap();
  }

  @override
  void dispose() {
    _isDisposed = true;
    mapController?.dispose();
    super.dispose();
  }

  // Load custom marker icons asynchronously
  Future<void> _loadMarkerIcons() async {
    try {
      ledIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/marker_led.png', // Assume this asset exists, or use default
      );
    } catch (e) {
      // Fallback to default icon
      ledIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  // Setup map data asynchronously
  void _setupMap() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    List<Place> places = [];
    if (provider.selectedOrigin != null && provider.selectedOrigin!.lat != 0) {
      places.add(provider.selectedOrigin!);
    }
    if (provider.selectedChurch != null) {
      places.add(provider.selectedChurch!);
    }
    if (provider.selectedReception != null) {
      places.add(provider.selectedReception!);
    }

    // Fetch LED sites near places
    List<LatLng> placeLatLngs = places.map((p) => LatLng(p.lat, p.lng)).toList();
    if (placeLatLngs.isNotEmpty) {
      try {
        final ledSitesData = await LedSitesService().findSitesNearPlaces(
          places: placeLatLngs,
          radiusMeters: 1000,
          maxResults: 5,
        );
        ledSites = ledSitesData.map((data) => Site.fromLedSiteData(data)).toList();
      } catch (e) {
        // Handle error, perhaps log
      }
    }

    // Add markers for places
    for (int i = 0; i < places.length; i++) {
      final place = places[i];
      markers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.lat, place.lng),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: _getPriceForPlace(place),
          ),
        ),
      );
    }

    // Add markers for LED sites
    for (final site in ledSites) {
      markers.add(
        Marker(
          markerId: MarkerId(site.id),
          position: site.position,
          icon: ledIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: site.name,
            snippet: site.displaySnippet,
          ),
        ),
      );
    }

    // Fetch routes with LED site as waypoint
    if (places.length > 1) {
      await _fetchRoutes(places, ledSites.isNotEmpty ? ledSites.first.position : null);
    }

    // Calculate camera bounds to fit all points
    _calculateCameraBounds();

    if (!_isDisposed && mounted) {
      setState(() {
        isLoadingRoutes = false;
      });
    }
  }

  // Fetch and draw polyline route using Directions API
  Future<void> _fetchRoutes(List<Place> places, LatLng? ledWaypoint) async {
    final placesService = PlacesService();
    List<Polyline> routePolylines = [];

    if (_isDisposed) return; // Early exit if disposed

    // Include LED site as waypoint if available
    List<LatLng> waypoints = [];
    if (ledWaypoint != null) {
      waypoints.add(ledWaypoint);
    }

    // Route from first to last place with intermediates as waypoints
    if (places.length >= 2) {
      final origin = LatLng(places.first.lat, places.first.lng);
      final destination = LatLng(places.last.lat, places.last.lng);
      List<LatLng> intermediateWaypoints = places.sublist(1, places.length - 1).map((p) => LatLng(p.lat, p.lng)).toList();
      intermediateWaypoints.addAll(waypoints);

      try {
        final routePoints = await placesService.getDirections(origin, destination, waypoints: intermediateWaypoints);
        routePolylines.add(
          Polyline(
            polylineId: const PolylineId('main_route'),
            points: routePoints,
            color: Colors.blue,
            width: 5,
          ),
        );
      } catch (e) {
        // Fallback to straight lines on API failure
        for (int i = 0; i < places.length - 1; i++) {
          final o = LatLng(places[i].lat, places[i].lng);
          final d = LatLng(places[i + 1].lat, places[i + 1].lng);
          routePolylines.add(
            Polyline(
              polylineId: PolylineId('route_$i'),
              points: [o, d],
              color: Colors.red,
              width: 3,
              patterns: [PatternItem.dash(10), PatternItem.gap(10)],
            ),
          );
        }
      }
    }

    if (!_isDisposed && mounted) {
      setState(() {
        polylines.addAll(routePolylines);
      });
    }
  }

  // Calculate camera bounds to fit all markers
  void _calculateCameraBounds() {
    if (markers.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in markers) {
      final pos = marker.position;
      minLat = minLat < pos.latitude ? minLat : pos.latitude;
      maxLat = maxLat > pos.latitude ? maxLat : pos.latitude;
      minLng = minLng < pos.longitude ? minLng : pos.longitude;
      maxLng = maxLng > pos.longitude ? maxLng : pos.longitude;
    }

    cameraBounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  String _getPriceForPlace(Place place) {
    switch (place.type) {
      case 'church':
        return '\$500';
      case 'reception':
        return '\$1000';
      default:
        return 'Price not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedding Route'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0), // Will be updated
              zoom: 10,
            ),
            markers: markers,
            polylines: polylines,
            // Optional Map ID to remove "AdvancedMarkers: false" warnings
            // cloudMapId: 'your_map_id_here',
            onMapCreated: (controller) {
              // Prevent setting controller if disposed
              if (!_isDisposed && mounted) {
                mapController = controller;
                if (cameraBounds != null) {
                  mapController!.animateCamera(
                    CameraUpdate.newLatLngBounds(cameraBounds!, 50),
                  );
                } else if (markers.isNotEmpty) {
                  mapController!.animateCamera(
                    CameraUpdate.newLatLng(markers.first.position),
                  );
                }
              }
            },
          ),
          if (isLoadingRoutes)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}