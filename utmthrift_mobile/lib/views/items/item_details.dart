// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/item_model.dart';
import 'package:utmthrift_mobile/services/auth_service.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/views/chat/chat_screen.dart';
import 'package:utmthrift_mobile/views/review/seller_review_profile_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class ItemDetailsScreen extends StatefulWidget {
  final int itemId;
  final String imageUrl;
  final String name;
  final double price;
  final String seller;
  final String condition;

  const ItemDetailsScreen({
    super.key,
    required this.itemId,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.seller,
    required this.condition,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late Future<Map<String, dynamic>?> _itemFuture;
  late CartViewModel _cartViewModel;
  late int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    final viewModel = Provider.of<ItemViewModel>(context, listen: false);
    _itemFuture = viewModel.fetchItemDetails(widget.itemId);
    _cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    AuthService.getCurrentUserId().then((userId) {
      if (userId != null) {
        _cartViewModel.loadCartItems(userId);
      }
    });
  }

  Future<void> _loadCurrentUserId() async {
    final id = await AuthService.getCurrentUserId();
    setState(() => currentUserId = id);
  }

  Future<void> _addToCart(Map<String, dynamic> itemData) async {
    try {
      await _cartViewModel.addItem(
        Item(
          id: itemData['id'],
          name: itemData['name'],
          price: double.parse(itemData['price'].toString()),
          description: itemData['description'] ?? '',
          condition: itemData['condition'] ?? '',
          imageUrls: itemData['images'] != null
              ? List<String>.from(itemData['images'])
              : [],
          category: itemData['category']?['name'] ?? '',
          seller: itemData['seller']?['name'] ?? '',
          sellerId: itemData['seller']?['id'],
        ),
        quantity: 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Item added to cart."),
            backgroundColor: AppColors.color13, // Green success
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add to cart: $e"),
            backgroundColor: AppColors.color8, // Red error
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          "Item Details",
          style: TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.color2, // Maroon app bar
        iconTheme: const IconThemeData(color: AppColors.base),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _itemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.color2),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.color8), // Red error text
              ),
            );
          }

          final item = snapshot.data;
          if (item == null) {
            return const Center(
              child: Text(
                'No item details available',
                style: TextStyle(color: AppColors.color10),
              ),
            );
          }

          final List<dynamic> imagesDynamic = item['images'] ?? [];
          final List<String> images =
              imagesDynamic.map((e) => e.toString()).toList();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Images Carousel
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.color12, // Light yellow background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: PageView.builder(
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                final imageUrl = images[index];
                                return Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: AppColors.color3,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppColors.color3,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Item Name
                  Text(
                    item['name'] ?? 'Unknown Item',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color10,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    'RM${num.tryParse(item['price'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color1, // Orange price
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Card
                  Card(
                    color: AppColors.color12,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Condition
                          _buildDetailRow(
                            icon: Icons.assignment_outlined,
                            label: 'Condition',
                            value: item['condition'] ?? 'Unknown',
                          ),
                          const SizedBox(height: 12),

                          // Category
                          _buildDetailRow(
                            icon: Icons.category_outlined,
                            label: 'Category',
                            value: item['category']?['name'] ?? 'Not available',
                          ),
                          const SizedBox(height: 12),

                          // Seller
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 20,
                                color: AppColors.color2,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Seller',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: () {
                                      final sellerId = item['seller']?['id'];
                                      if (sellerId != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SellerReviewProfilePage(sellerId: sellerId),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Seller ID not available.'),
                                            backgroundColor: AppColors.color8,
                                          ),
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 30),
                                    ),
                                    child: Text(
                                      item['seller']?['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.color2,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Card
                  Card(
                    color: AppColors.color12,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.color10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['description'] ?? 'No description available',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.color10.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>?>(
        future: _itemFuture,
        builder: (context, snapshot) {
          final isDataAvailable = snapshot.hasData && snapshot.data != null;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.base,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Chat Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (snapshot.data?['seller'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Seller information not available."),
                            backgroundColor: AppColors.color8,
                          ),
                        );
                        return;
                      }

                      final sellerId = snapshot.data!['seller']['id'];
                      final sellerName = snapshot.data!['seller']['name'];
                      final currentUserId = await AuthService.getCurrentUserId();

                      if (currentUserId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("User not logged in."),
                            backgroundColor: AppColors.color8,
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            currentUserId: currentUserId,
                            sellerId: sellerId,
                            itemId: snapshot.data!['id'],
                            itemName: snapshot.data!['name'],
                            sellerName: sellerName,
                            initialMessage: "Hi, I want to ask regarding '${snapshot.data!['name']}'",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat, color: AppColors.base),
                    label: const Text(
                      "Chat",
                      style: TextStyle(color: AppColors.base),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.color7, // Blue
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Cart Button
                Consumer<CartViewModel>(
                  builder: (context, cartViewModel, child) {
                    if (!isDataAvailable) {
                      return Expanded(
                        child: ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.shopping_cart, color: AppColors.base),
                          label: const Text(
                            "Cart",
                            style: TextStyle(color: AppColors.base),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.color9, // Grey
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    }

                    final item = Item(
                      id: snapshot.data!['id'],
                      name: snapshot.data!['name'],
                      price: double.parse(snapshot.data!['price'].toString()),
                      description: snapshot.data!['description'] ?? '',
                      condition: snapshot.data!['condition'] ?? '',
                      imageUrls: snapshot.data!['images'] != null
                          ? List<String>.from(snapshot.data!['images'])
                          : [],
                      category: snapshot.data!['category']?['name'] ?? '',
                      seller: snapshot.data!['seller']?['name'] ?? '',
                      sellerId: snapshot.data!['seller']?['id'],
                    );

                    final isInCart = cartViewModel.isItemInCart(item);

                    return Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isInCart ? null : () => _addToCart(snapshot.data!),
                        icon: Icon(
                          isInCart ? Icons.check_circle : Icons.shopping_cart,
                          color: AppColors.base,
                        ),
                        label: Text(
                          isInCart ? "In Cart" : "Add to Cart",
                          style: const TextStyle(color: AppColors.base),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart ? AppColors.color9 : AppColors.color2, // Grey or Maroon
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.color2,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.color10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}