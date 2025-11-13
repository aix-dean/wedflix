import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart' as my_auth;
import '../widgets/venue_card.dart';
import '../widgets/category_filter.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import '../models/venue.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  List<Place> _places = [];
  List<Venue> _venues = [];
  bool _isLoadingPlaces = true;
  String? _placesError;

  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();

  @override
  void initState() {
    super.initState();
    _fetchNearbyPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchNearbyPlaces() async {
    setState(() {
      _isLoadingPlaces = true;
      _placesError = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final places = await _placesService.getNearbyPlaces(position.latitude, position.longitude);
      _places = places;
      _venues = places.map(_convertPlaceToVenue).toList();
    } catch (e) {
      _placesError = e.toString();
    } finally {
      setState(() {
        _isLoadingPlaces = false;
      });
    }
  }

  Venue _convertPlaceToVenue(Place place) {
    return Venue(
      id: place.id,
      iD: place.id,
      name: place.name,
      type: place.type,
      price: 0, // Default price since Places API doesn't provide pricing
      location: place.address,
      description: 'Located at ${place.address}',
      rating: 4.0, // Default rating
      reviewCount: 0, // Default review count
      availability: [], // Empty availability
      media: place.photoUrl != null ? [
        ProductMedia(
          url: place.getPhotoUrl(_placesService.apiKey) ?? 'https://via.placeholder.com/400/200?text=No+Image',
          distance: '0km', // Default distance
          type: 'image',
          isVideo: false,
        )
      ] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<my_auth.AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.currentUser != null) {
              return Text('Welcome, ${authProvider.currentUser!.email}');
            } else {
              return const Text('WedFlix');
            }
          },
        ),
        centerTitle: true,
        actions: [
          Consumer<my_auth.AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.currentUser != null) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await authProvider.signOut();
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD8DCE0)),
                  borderRadius: BorderRadius.circular(43),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Perfect fit for you',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Wedding Date ∙ Preferred Locations',
                            style: TextStyle(
                              color: Color(0xFF717375),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD8DCE0)),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryFilter(
                  label: 'All',
                  isSelected: _selectedCategory == 'All',
                  onTap: () => setState(() => _selectedCategory = 'All'),
                ),
                CategoryFilter(
                  label: 'Hotels',
                  isSelected: _selectedCategory == 'hotel',
                  onTap: () => setState(() => _selectedCategory = 'hotel'),
                ),
                CategoryFilter(
                  label: 'Churches',
                  isSelected: _selectedCategory == 'church',
                  onTap: () => setState(() => _selectedCategory = 'church'),
                ),
                CategoryFilter(
                  label: 'Reception',
                  isSelected: _selectedCategory == 'reception',
                  onTap: () => setState(() => _selectedCategory = 'reception'),
                ),
              ],
            ),
          ),

          // Venues List
          Expanded(
            child: _isLoadingPlaces
                ? const Center(child: CircularProgressIndicator())
                : _placesError != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error loading places: $_placesError'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchNearbyPlaces,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          List<Venue> venues = _selectedCategory == 'All'
                              ? _venues
                              : _venues.where((v) => v.type == _selectedCategory).toList();

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: venues.length,
                            itemBuilder: (context, index) {
                              return VenueCard(venue: venues[index]);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}