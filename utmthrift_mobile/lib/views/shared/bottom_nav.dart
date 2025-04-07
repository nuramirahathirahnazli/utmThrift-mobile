// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/pages/home_screen.dart';
import 'package:utmthrift_mobile/views/pages/profile_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = const PlaceholderPage(title: "Explore Page - Coming Soon");
        break;
      case 2:
        page = const PlaceholderPage(title: "Notifications Page - Coming Soon");
        break;
      case 3:
        page = const PlaceholderPage(title: "My Likes Page - Coming Soon");
        break;
      case 4:
        page = ProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: AppColors.color2,
      unselectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'My Likes'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
      ],
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: const TextStyle(fontSize: 18))),
    );
  }
}