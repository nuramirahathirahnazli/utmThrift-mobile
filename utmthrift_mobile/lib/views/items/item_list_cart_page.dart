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
      setState(() => userId = storedUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        backgroundColor: AppColors.base,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.color2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.color2, // Maroon app bar
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.base),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: cartViewModel.loadCartItems(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.color2),
            );
          }

          final cartList = cartViewModel.items.values.toList();

          if (cartList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.color3, // Light pink icon
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color10, // Black text
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Browse items and add them to your cart",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.color10.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Total items count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.color12, // Light yellow background
                child: Row(
                  children: [
                    Text(
                      "${cartList.length} ${cartList.length == 1 ? 'Item' : 'Items'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.color10,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: cartList.length,
                  itemBuilder: (context, index) {
                    final item = cartList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: AppColors.base,
                      elevation: 0,
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
                              child: Container(
                                width: 80,
                                height: 80,
                                color: AppColors.color12, // Light yellow background
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl.first,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        size: 30,
                                        color: AppColors.color3, // Light pink icon
                                      ),
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
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.color10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "RM ${item.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: AppColors.color2, // Maroon price
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Seller: ${item.sellerName}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.color10.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Actions
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.color4, // Red delete icon
                                  ),
                                  onPressed: () async {
                                    await cartViewModel.removeItem(item.itemId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Item removed from cart'),
                                        backgroundColor: AppColors.color13, // Green success
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.color2, // Maroon button
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
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
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.base, // Cream text
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}