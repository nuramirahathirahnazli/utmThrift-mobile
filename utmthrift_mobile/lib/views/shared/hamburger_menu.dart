// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class HamburgerMenu extends StatelessWidget {
  final String userType;
  final VoidCallback onLogout;

  const HamburgerMenu({
    Key? key,
    required this.userType,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange),
            child: Text(
              'UTMThrift Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),

          if (userType == 'Seller') ...[
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('My Listings'),
              onTap: () {
                Navigator.pushNamed(context, '/seller-listings');
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('My Orders'),
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
          ],

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Help & About'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
