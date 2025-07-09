// ignore_for_file: unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/chatmessage_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/user_viewmodel.dart';
import 'package:utmthrift_mobile/views/chat/chat_list_page.dart';
import 'package:utmthrift_mobile/views/chat/chat_screen.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class TopNavBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearchSubmitted;
  final int cartCount;
  final VoidCallback onCartPressed;
  final int chatCount;

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
  State<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends State<TopNavBar> {
  @override
  void initState() {
    super.initState();
    _loadChatList(); // Load chat count when widget is initialized
  }

  Future<void> _loadChatList() async {
    try {
      final chatVM = Provider.of<ChatMessageViewModel>(context, listen: false);
      await chatVM.fetchUnreadMessageCount(); // Update unread count
      if (mounted) {
        setState(() {}); // Ensure UI updates
      }
    } catch (e) {
      print("Failed to refresh chat count: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final currentUserId = userVM.userId;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.base.withOpacity(0.9),
      elevation: 0,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: widget.searchController,
          onSubmitted: widget.onSearchSubmitted,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: "Search anything in UTM Thrift",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
      ),
      actions: [
        // Cart icon
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: widget.onCartPressed,
            ),
            if (widget.cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: _buildBadge(widget.cartCount),
              ),
          ],
        ),

        // Chat icon
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                if (currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not logged in")),
                  );
                  return;
                }

                if (widget.sellerId != null &&
                    widget.itemId != null &&
                    widget.itemName != null &&
                    widget.sellerName != null) {
                  // Navigating to specific chat screen with item context
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        sellerId: widget.sellerId!,
                        itemId: widget.itemId!,
                        itemName: widget.itemName!,
                        sellerName: widget.sellerName!,
                        currentUserId: currentUserId,
                        isSeller: widget.isSeller ?? false,
                      ),
                    ),
                  ).then((_) {
                    _loadChatList(); // Refresh chat count after returning
                  });
                } else {
                  // Navigating to the chat list
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatListPage(currentUserId: currentUserId),
                    ),
                  ).then((_) {
                    _loadChatList(); // Refresh chat count after returning
                  });
                }
              }

            ),
            if (widget.chatCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: _buildBadge(widget.chatCount),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }
}
