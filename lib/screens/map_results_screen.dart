import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/places_service.dart';
import '../services/led_sites_service.dart';
import '../models/site.dart';
import '../widgets/site_card.dart';
import 'site_details_screen.dart';

class MapResultsScreen extends StatefulWidget {
  const MapResultsScreen({super.key});

  @override
  State<MapResultsScreen> createState() => _MapResultsScreenState();
}

class _MapResultsScreenState extends State<MapResultsScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool isLoadingRoutes = true;
  bool isLoadingLedSites = true;
  bool _isDisposed = false;
  LatLng? _initialCameraPosition;
  List<LatLng> _routePoints = []; // Store route points for LED sites
  List<Site> _ledSites = []; // Store LED sites for the sheet
  List<Place> _places = []; // Store places for LED sites

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  @override
  void dispose() {
    _isDisposed = true;
    mapController?.dispose();
    super.dispose();
  }

  LatLngBounds? _calculateBounds(List<Place> places) {
    if (places.isEmpty) return null;

    double minLat = places[0].lat;
    double maxLat = places[0].lat;
    double minLng = places[0].lng;
    double maxLng = places[0].lng;

    for (final place in places) {
      minLat = minLat < place.lat ? minLat : place.lat;
      maxLat = maxLat > place.lat ? maxLat : place.lat;
      minLng = minLng < place.lng ? minLng : place.lng;
      maxLng = maxLng > place.lng ? maxLng : place.lng;
    }

    // Add padding to bounds
    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    return LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
  }

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

    _places = places; // Store places for LED sites

    // Calculate initial camera position from first place or default
    if (places.isNotEmpty) {
      _initialCameraPosition = LatLng(places[0].lat, places[0].lng);
    } else {
      // Fallback to a default location (e.g., Manila, Philippines)
      _initialCameraPosition = const LatLng(14.5995, 120.9842);
    }

    // Add venue markers
    for (int i = 0; i < places.length; i++) {
      final place = places[i];
      markers.add(
        Marker(
          markerId: MarkerId('venue_${place.id}'),
          position: LatLng(place.lat, place.lng),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: _getPriceForPlace(place),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Blue for venues
        ),
      );
    }

    // Fetch actual routes between places
    if (places.length > 1) {
      await _fetchRoutes(places);
    }

    // Fetch LED sites along the route or near places
    if (_routePoints.isNotEmpty) {
      await _fetchLedSites();
    } else if (_places.isNotEmpty) {
      await _fetchLedSitesNearPlaces();
    } else {
      setState(() {
        isLoadingLedSites = false;
      });
    }

    if (!_isDisposed && mounted) {
      setState(() {
        isLoadingRoutes = false;
      });

      // Update camera to show all markers after everything is loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mapController != null && places.isNotEmpty) {
          final bounds = _calculateBounds(places);
          if (bounds != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 50),
            );
          }
        }
      });
    }
  }

  Future<void> _fetchRoutes(List<Place> places) async {
    final placesService = PlacesService();
    List<Polyline> routePolylines = [];
    _routePoints.clear(); // Reset route points

    // Create routes between consecutive places
    for (int i = 0; i < places.length - 1; i++) {
      if (_isDisposed) return; // Early exit if disposed

      final origin = LatLng(places[i].lat, places[i].lng);
      final destination = LatLng(places[i + 1].lat, places[i + 1].lng);

      try {
        final routePoints = await placesService.getDirections(origin, destination);
        _routePoints.addAll(routePoints); // Collect all route points for LED sites

        routePolylines.add(
          Polyline(
            polylineId: PolylineId('route_$i'),
            points: routePoints,
            color: Colors.blue,
            width: 5,
          ),
        );
      } catch (e) {
        // Fallback to straight line if directions fail
        routePolylines.add(
          Polyline(
            polylineId: PolylineId('route_$i'),
            points: [origin, destination],
            color: Colors.red, // Red to indicate fallback
            width: 3,
            patterns: [PatternItem.dash(10), PatternItem.gap(10)],
          ),
        );
        _routePoints.addAll([origin, destination]); // Add fallback points
      }
    }

    if (!_isDisposed && mounted) {
      setState(() {
        polylines.addAll(routePolylines);
      });
    }
  }

  Future<void> _fetchLedSites() async {
    if (_routePoints.isEmpty) {
      setState(() {
        isLoadingLedSites = false;
      });
      return;
    }

    try {
      final ledSitesService = LedSitesService();
      final ledSites = await ledSitesService.findSitesAlongRoute(
        routePoints: _routePoints,
        radiusMeters: 1000, // 1000 meters from route
        maxResults: 50, // Limit to 50 LED sites
      );

      // Debug logging
      print("Found ${ledSites.length} LED sites along route");

      // Convert to Site objects for the sheet
      final sites = ledSites.map((site) => Site.fromLedSiteData(site)).toList();

      // Create markers for LED sites
      final ledMarkers = ledSites.map((site) {
        final position = LatLng(site['position']['lat'], site['position']['lng']);
        return Marker(
          markerId: MarkerId(site['markerId']),
          position: position,
          infoWindow: InfoWindow(
            title: site['infoWindowTitle'],
            snippet: site['infoWindowSnippet'],
            onTap: () => _showLedSiteDetails(site),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Green for LED sites
        );
      }).toSet();

      if (!_isDisposed && mounted) {
        setState(() {
          markers.addAll(ledMarkers);
          _ledSites = sites;
          isLoadingLedSites = false;
        });
      }
    } catch (e) {
      // If LED sites fail to load, just continue without them
      if (!_isDisposed && mounted) {
        setState(() {
          isLoadingLedSites = false;
        });
      }
    }
  }

  Future<void> _fetchLedSitesNearPlaces() async {
    try {
      final ledSitesService = LedSitesService();
      final placeLatLngs = _places.map((p) => LatLng(p.lat, p.lng)).toList();
      final ledSites = await ledSitesService.findSitesNearPlaces(
        places: placeLatLngs,
        radiusMeters: 1000, // 1 km from venues
        maxResults: 50, // Limit to 50 LED sites
      );

      // Debug logging
      print("Found ${ledSites.length} LED sites near places");

      // Convert to Site objects for the sheet
      final sites = ledSites.map((site) => Site.fromLedSiteData(site)).toList();

      // Create markers for LED sites
      final ledMarkers = ledSites.map((site) {
        final position = LatLng(site['position']['lat'], site['position']['lng']);
        return Marker(
          markerId: MarkerId(site['markerId']),
          position: position,
          infoWindow: InfoWindow(
            title: site['infoWindowTitle'],
            snippet: site['infoWindowSnippet'],
            onTap: () => _showLedSiteDetails(site),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Green for LED sites
        );
      }).toSet();

      if (!_isDisposed && mounted) {
        setState(() {
          markers.addAll(ledMarkers);
          _ledSites = sites;
          isLoadingLedSites = false;
        });
      }
    } catch (e) {
      // If LED sites fail to load, just continue without them
      if (!_isDisposed && mounted) {
        setState(() {
          isLoadingLedSites = false;
        });
      }
    }
  }

  void _showLedSiteDetails(Map<String, dynamic> site) {
    // Show bottom sheet with LED site details
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              site['infoWindowTitle'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '₱${site['price'].toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(site['infoWindowSnippet']),
            const SizedBox(height: 8),
            Text('${site['distanceMeters'].toStringAsFixed(0)} meters from route'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
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
        title: const Text('Selected Venues'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition ?? const LatLng(14.5995, 120.9842),
              zoom: 12,
            ),
            markers: markers,
            polylines: polylines,
            onMapCreated: (controller) {
              // Prevent setting controller if disposed
              if (!_isDisposed && mounted) {
                mapController = controller;
              }
            },
          ),
          if (isLoadingRoutes || isLoadingLedSites)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // DraggableScrollableSheet for LED sites (always visible after loading)
          if (!isLoadingLedSites)
            DraggableScrollableSheet(
              initialChildSize: 0.25, // 25% of screen height
              minChildSize: 0.25, // Minimum 25%
              maxChildSize: 0.8, // Maximum 80%
              snap: true, // Enable snapping
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Grabber handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 60,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      // Summary title
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _ledSites.isNotEmpty ? '${_ledSites.length} Sites' : 'LED Billboard Sites',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Scrollable list or empty state
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            // Allow the sheet to be dragged when at the top of the list
                            if (notification.metrics.pixels <= 0 && notification is ScrollUpdateNotification) {
                              return false; // Let parent handle the scroll
                            }
                            return true; // Handle scroll in the list
                          },
                          child: _ledSites.isNotEmpty
                              ? ListView.builder(
                                  controller: scrollController,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: _ledSites.length,
                                  itemBuilder: (context, index) {
                                    final site = _ledSites[index];
                                    return SiteCard(
                                      site: site,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SiteDetailsScreen(
                                            site: site,
                                            selectedDate: Provider.of<AppProvider>(context, listen: false).selectedStartDate!,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : SingleChildScrollView(
                                  controller: scrollController,
                                  physics: const ClampingScrollPhysics(),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.business,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No LED billboard sites found along this route',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try adjusting your route or search in a different area',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}