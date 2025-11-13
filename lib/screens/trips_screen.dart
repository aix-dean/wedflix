import 'package:flutter/material.dart';
import '../widgets/bottom_nav_component.dart';
import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'inbox_screen.dart';
import 'profile_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  int currentIndex = 2; // Trips is selected
  bool hasInboxNotifications = false; // TODO: Connect to provider for notifications

  void _onTabSelected(int index) {
    if (index == currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const WishlistScreen();
        break;
      case 2:
        screen = const TripsScreen();
        break;
      case 3:
        screen = const InboxScreen();
        break;
      case 4:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Container(
                padding: const EdgeInsets.all(24),
                child: const Text(
                  'Trips',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),

              // Upcoming reservations
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming reservations',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Booking card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Container(
                            height: 165,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              image: DecorationImage(
                                image: NetworkImage('https://picsum.photos/329/165?random=3'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Yonkers',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    height: 1.33,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Private room in home hosted by Craig',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  height: 1,
                                  color: const Color(0xFFD8DCE0),
                                ),
                                const SizedBox(height: 24),

                                // Dates and location
                                Row(
                                  children: [
                                    // Dates
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Feb',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '13 - 14',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '2023',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 15),
                                    Container(
                                      width: 1,
                                      height: 66,
                                      color: const Color(0xFFD8DCE0),
                                    ),
                                    const SizedBox(width: 15),

                                    // Location
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Yonkers, New York',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          'United States',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Explore section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore things to do near Yonkers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recommendation cards
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildRecommendationCard(
                            'Just for you',
                            '18 experiences',
                            'https://picsum.photos/53/53?random=4',
                          ),
                          const SizedBox(width: 24),
                          _buildRecommendationCard(
                            'Food',
                            '23 experiences',
                            'https://picsum.photos/53/53?random=5',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavComponent(
        currentIndex: currentIndex,
        onTabSelected: _onTabSelected,
        hasInboxNotifications: hasInboxNotifications,
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String subtitle, String imageUrl) {
    return Row(
      children: [
        Container(
          width: 53,
          height: 53,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF717375),
              ),
            ),
          ],
        ),
      ],
    );
  }
}