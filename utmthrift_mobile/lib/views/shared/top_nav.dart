// ignore_for_file: unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/user_viewmodel.dart';
import 'package:utmthrift_mobile/views/chat/chat_list_page.dart';
import 'package:utmthrift_mobile/views/chat/chat_screen.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearchSubmitted;
  final int cartCount;
  final VoidCallback onCartPressed;
  final int chatCount;

  //optional parameters for chat screen
  final int? sellerId;
  final int? itemId;
  final String? itemName;
  final String? sellerName;
  final bool? isSeller;

  const TopNavBar({
    super.key,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.cartCount,
    required this.onCartPressed,
    required this.chatCount,
    this.sellerId,
    this.itemId,
    this.itemName,
    this.sellerName,
    this.isSeller, 
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final currentUserId = userVM.userId;

    print('chatCount in TopNavBar: $chatCount');

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
          // Cart Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: onCartPressed,
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Chat Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  final userVM = Provider.of<UserViewModel>(context, listen: false);
                  final currentUserId = userVM.userId;

                  if (currentUserId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not logged in")),
                    );
                    return;
                  }

                  if (sellerId != null && itemId != null && itemName != null && sellerName != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          sellerId: sellerId!,
                          itemId: itemId!,
                          itemName: itemName!,
                          sellerName: sellerName!,
                          currentUserId: currentUserId,
                          isSeller: isSeller ?? false,  // pass isSeller here
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatListPage(currentUserId: currentUserId),
                      ),
                    );
                  }
                },
              ),
    if (chatCount > 0)
      Positioned(
        right: 6,
        top: 6,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: const BoxConstraints(
            minWidth: 16,
            minHeight: 16,
          ),
          child: Text(
            '$chatCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],

      ),
    );
  }
}
