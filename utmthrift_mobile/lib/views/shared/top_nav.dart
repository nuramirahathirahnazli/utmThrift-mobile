import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearchSubmitted;

  const TopNavBar({
    super.key,
    required this.searchController,
    required this.onSearchSubmitted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => AppBar(
        backgroundColor: AppColors.base.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: searchController,
            onSubmitted: onSearchSubmitted,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: "Search anything in UTM Thrift",
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat), onPressed: () {}),
        ],
      ),
    );
  }
}
