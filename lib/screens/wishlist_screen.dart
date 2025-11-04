import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFD8DCE0), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Wishlist is selected
        selectedItemColor: const Color(0xFFD42F4D),
        unselectedItemColor: const Color(0xFF717375),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airplanemode_active),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // TODO: Navigate to different screens
        },
      ),
    );
  }
}