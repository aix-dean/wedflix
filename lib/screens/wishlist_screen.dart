import 'package:flutter/material.dart';
import '../widgets/bottom_nav_component.dart';
import 'home_screen.dart';
import 'trips_screen.dart';
import 'inbox_screen.dart';
import 'profile_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int currentIndex = 1; // Wishlist is selected
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Container(
              padding: const EdgeInsets.all(24),
              child: const Text(
                'Wishlist',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),

            // Wishlist items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildWishlistItem(
                    'For Alice and John',
                    'Jan 15, 2026',
                    'https://picsum.photos/70/70?random=1',
                  ),
                  const SizedBox(height: 16),
                  _buildWishlistItem(
                    'Jacelyn and Mario',
                    'Feb 14, 2026',
                    'https://picsum.photos/70/70?random=2',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavComponent(
        currentIndex: currentIndex,
        onTabSelected: _onTabSelected,
        hasInboxNotifications: hasInboxNotifications,
      ),
    );
  }

  Widget _buildWishlistItem(String title, String date, String imageUrl) {
    return Row(
      children: [
        // Image
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Text
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
              date,
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