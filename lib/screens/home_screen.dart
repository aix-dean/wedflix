import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/venue_card.dart';
import '../widgets/category_filter.dart';
import 'search_screen.dart';
import '../models/venue.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WedFlix'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
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
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                List<Venue> venues = _selectedCategory == 'All'
                    ? provider.venues
                    : provider.venues.where((v) => v.type == _selectedCategory).toList();

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