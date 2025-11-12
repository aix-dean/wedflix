import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavComponent extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final bool hasInboxNotifications;

  const BottomNavComponent({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.hasInboxNotifications,
  });

  @override
  State<BottomNavComponent> createState() => _BottomNavComponentState();
}

class _BottomNavComponentState extends State<BottomNavComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFD8DCE0), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.currentIndex,
        selectedItemColor: const Color(0xFFD42F4D),
        unselectedItemColor: const Color(0xFF717375),
        iconSize: 24.0,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              widget.currentIndex == 2
                  ? 'assets/nav_icons/Vector_active.svg'
                  : 'assets/nav_icons/Vector_inactive.svg',
            ),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                SvgPicture.asset(
                  widget.currentIndex == 3
                      ? 'assets/nav_icons/Message_active.svg'
                      : 'assets/nav_icons/Message.svg',
                ),
                if (widget.hasInboxNotifications)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              widget.currentIndex == 4
        ? 'assets/nav_icons/User_active.svg'
        : 'assets/nav_icons/User.svg',
            ),
            label: 'Profile',
          ),
        ],
        onTap: widget.onTabSelected,
      ),
    );
  }
}