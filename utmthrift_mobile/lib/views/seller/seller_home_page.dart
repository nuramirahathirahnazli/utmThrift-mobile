// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, unused_import

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/items/item_card_explore.dart';
import 'package:utmthrift_mobile/views/items/item_category.dart';
import 'package:utmthrift_mobile/views/pages/profile_page.dart';
import 'package:utmthrift_mobile/views/shared/bottom_nav.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import 'package:utmthrift_mobile/views/shared/hamburger_menu.dart';
import 'package:utmthrift_mobile/views/shared/top_nav.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedIndex = 0;
  final String userType = 'Seller';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HamburgerMenu(
        userType: 'Seller', // or pass dynamically
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      backgroundColor: AppColors.base,
      appBar: _selectedIndex == 0 ? const TopNavBar() : null,
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavBar(
      currentIndex: _selectedIndex,
      userType: userType,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreenContent(); 
      case 1:
        return const Center(child: Text("Explore Page - Coming Soon"));
      case 2:
        return const Center(child: Text("Add Item Page - Coming Soon"));
      case 3:
        return const Center(child: Text("Notifications Page - Coming Soon"));
      case 4:
        return ProfilePage(userType: userType,);
      default:
        return const HomeScreenContent();
    }
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Don't Miss This", onSeeMore: () {}),
            _buildHorizontalList(),
            const SizedBox(height: 20),
            _buildSectionHeader("Popular Categories"),
            _buildCategoryList(),
            const SizedBox(height: 20),
            _buildSectionHeader("Daily Explore"),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (onSeeMore != null)
          TextButton(onPressed: onSeeMore, child: const Text("See More"))
      ],
    );
  }

  Widget _buildHorizontalList() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPromoCard('assets/event1.png'),
          _buildPromoCard('assets/event2.png'),
          _buildPromoCard('assets/event3.png'),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(imagePath, width: 120, height: 150, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCategoryList() {
    List<Map<String, String>> categories = [
      {"imageUrl": "https://via.placeholder.com/150", "name": "Shoes"},
      {"imageUrl": "https://via.placeholder.com/150", "name": "Men's Clothes"},
      {"imageUrl": "https://via.placeholder.com/150", "name": "Women's Clothes"},
      {"imageUrl": "https://via.placeholder.com/150", "name": "Accessories"},
      {"imageUrl": "https://via.placeholder.com/150", "name": "Bags"},
      {"imageUrl": "https://via.placeholder.com/150", "name": "Electronics"},
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryItemsScreen(categoryName: categories[index]["name"]!),
                ),
              );
            },
            child: _buildCategoryCard(
              categories[index]["imageUrl"]!,
              categories[index]["name"]!,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(String imageUrl, String name) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(imageUrl, height: 60, width: 60, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: 6, // Placeholder count
      itemBuilder: (context, index) {
        return ItemCardExplore(
          imageUrl: "https://via.placeholder.com/150",
          name: "Product $index",
          price: (index + 1) * 10.0,
          seller: "Seller $index",
          condition: "New",
        );
      },
    );
  }
}
