import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info section
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Avatar placeholder
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.person, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'John',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to full profile
                          },
                          child: const Text(
                            'View profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Earn money section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFD8DCE0), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.attach_money, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Earn money from your extra space',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF3D3F40),
                            ),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () {
                              // TODO: Navigate to learn more
                            },
                            child: const Text(
                              'Learn more',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Account Settings
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSettingItem('Personal information', Icons.person_outline),
                    _buildDivider(),
                    _buildSettingItem('Payments and payouts', Icons.attach_money),
                    _buildDivider(),
                    _buildSettingItem('Translation', Icons.translate),
                    _buildDivider(),
                    _buildSettingItem('Notifications', Icons.notifications_none),
                    _buildDivider(),
                    _buildSettingItem('Privacy and sharing', Icons.lock_outline),
                    _buildDivider(),
                    _buildSettingItem('Travel for work', Icons.work_outline),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFD8DCE0),
      margin: const EdgeInsets.symmetric(vertical: 0),
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
        currentIndex: 4, // Profile is selected
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