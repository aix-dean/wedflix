import 'package:flutter/material.dart';
import '../widgets/bottom_nav_component.dart';
import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'trips_screen.dart';
import 'profile_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 3; // Inbox is selected
  bool hasInboxNotifications = true; // Has notifications

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                'Inbox',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Messages',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF989B9D),
                      ),
                    ),
                  ),
                ],
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                unselectedLabelColor: const Color(0xFF989B9D),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Messages tab
                  ListView(
                    children: [
                      _buildMessageItem(
                        'Craig',
                        'Alright got it we\'ll make do thanks a lot',
                        null,
                        null,
                      ),
                      _buildDivider(),
                      _buildMessageItem(
                        'Craig',
                        'Airbnb update: Reservation canceled',
                        'Yonkers',
                        'Canceled • Feb 13 - 14, 2023',
                      ),
                      _buildDivider(),
                      _buildMessageItem(
                        'Erin',
                        'New date and time request',
                        'New York',
                        'Request pending',
                      ),
                    ],
                  ),

                  // Notifications tab
                  const Center(
                    child: Text('No notifications yet'),
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

  Widget _buildMessageItem(String name, String message, String? location, String? status) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.person, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and location
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (location != null) ...[
                      const Text(
                        ' • ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF717375),
                        ),
                      ),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF717375),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: status == null ? Colors.black : Colors.black,
                    fontWeight: status == null ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF717375),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFD8DCE0),
      margin: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}