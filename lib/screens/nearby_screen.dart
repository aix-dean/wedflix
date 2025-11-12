import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  List<Place> nearbyPlaces = [];
  bool isLoading = false;
  String? errorMessage;

  final LocationService locationService = LocationService();
  final PlacesService placesService = PlacesService();

  @override
  void initState() {
    super.initState();
    _fetchNearbyPlaces();
  }

  Future<void> _fetchNearbyPlaces() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      nearbyPlaces = [];
    });
    try {
      final position = await locationService.getCurrentLocation();
      final places = await placesService.getNearbyPlaces(position.latitude, position.longitude);
      nearbyPlaces = places;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Wedding Venues'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : ListView.builder(
                  itemCount: nearbyPlaces.length,
                  itemBuilder: (context, index) {
                    final place = nearbyPlaces[index];
                    return ListTile(
                      title: Text(place.name),
                      subtitle: Text('${place.address} (${place.type})'),
                    );
                  },
                ),
    );
  }
}