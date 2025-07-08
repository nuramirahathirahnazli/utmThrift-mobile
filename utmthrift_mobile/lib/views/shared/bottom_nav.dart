// ignore_for_file: use_super_parameters, unused_element

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String userType; 
  final ValueChanged<int> onTap;

  const BottomNavBar({
    Key? key, 
    required this.currentIndex, 
    required this.userType,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.color2,
      unselectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(
          icon: Icon(userType == 'Seller' ? Icons.add : Icons.receipt_long),
          label: userType == 'Seller' ? 'Upload' : 'My Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(userType == 'Seller' ? Icons.list_alt : Icons.favorite),
          label: userType == 'Seller' ? 'My Items' : 'My Likes',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
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
