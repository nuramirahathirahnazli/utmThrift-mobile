// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/services/auth_service.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/views/items/item_checkout_details_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cartViewModel = CartViewModel();
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchCart();
  }

  Future<void> _loadUserIdAndFetchCart() async {
    final storedUserId = await AuthService.getCurrentUserId();
    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        backgroundColor: AppColors.base,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.color1),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: AppColors.color10)),
        backgroundColor: AppColors.color5,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.color10),
        centerTitle: true,
      ),
      body: FutureBuilder(
  future: cartViewModel.loadCartItems(userId!),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.color1),
      );
    }

    final cartList = cartViewModel.items.values.toList();

    if (cartList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 60, color: AppColors.color3),
            SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 18, color: AppColors.color2),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cartList.length,
      itemBuilder: (context, index) {
        final item = cartList[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: AppColors.base,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.color3.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Item Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: AppColors.color9,
                          child: const Icon(Icons.image_not_supported,
                              size: 30, color: AppColors.color3),
                        ),
                ),
                const SizedBox(width: 12),
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.color10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "RM ${item.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppColors.color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Seller: ${item.sellerName}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.color2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.color4),
                      onPressed: () async {
                        await cartViewModel.removeItem(item.itemId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Item removed from cart'),
                            backgroundColor: AppColors.color13,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                        setState(() {}); // Refresh the list
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.color1,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutDetailsPage(item: item),
                          ),
                        );
                      },
                      child: const Text(
                        "Checkout",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  },
),

    );
  }
}