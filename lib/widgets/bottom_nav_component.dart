import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavComponent extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const BottomNavComponent({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
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
            icon: SvgPicture.asset(
              'assets/nav_icons/Message.svg',
            ),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/nav_icons/User.svg',
            ),
            label: 'Profile',
          ),
        ],
        onTap: widget.onTabSelected,
      ),
    );
  }
}