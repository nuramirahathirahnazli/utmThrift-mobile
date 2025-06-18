// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/item_model.dart';
import 'package:utmthrift_mobile/services/auth_service.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/views/chat/chat_screen.dart';
import 'package:utmthrift_mobile/views/review/seller_review_profile_page.dart';


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
  }

  Future<void> _loadCurrentUserId() async {
  final id = await AuthService.getCurrentUserId();
  setState(() {
    currentUserId = id;
  });
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
          const SnackBar(content: Text("Item added to cart.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add to cart: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Item Details")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _itemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final item = snapshot.data;
          if (item == null) {
            return const Center(child: Text('No item details available'));
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
                  Text(
                    item['name'] ?? 'Unknown Item',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: ${item['category']?['name'] ?? 'Not available'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: RM${num.tryParse(item['price'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['description'] ?? 'No description available',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Condition: ${item['condition'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Seller: ',
                        style: TextStyle(fontSize: 16),
                      ),
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
                              const SnackBar(content: Text('Seller ID not available.')),
                            );
                          }
                        },
                        child: Text(
                          item['seller']?['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Images:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: images.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final imageUrl = images[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(
                                  imageUrl,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image $imageUrl: $error');
                                    return const Icon(Icons.broken_image, size: 50);
                                  },
                                ),
                              );
                            },
                          )
                        : const Center(child: Text("No images available")),
                  ),
                  const SizedBox(height: 100),
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (snapshot.data?['seller'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Seller information not available.")),
                        );
                        return;
                      }

                      final sellerId = snapshot.data!['seller']['id'];
                      final sellerName = snapshot.data!['seller']['name'];
                      final currentUserId = await AuthService.getCurrentUserId();

                      if (currentUserId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not logged in.")),
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
                    icon: const Icon(Icons.chat),
                    label: const Text("Chat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<CartViewModel>(
                  builder: (context, cartViewModel, child) {
                    if (!isDataAvailable) {
                      return Expanded(
                        child: ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text("Cart"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 14),
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
                        onPressed:
                            isInCart ? null : () => _addToCart(snapshot.data!),
                        icon: Icon(
                          isInCart
                              ? Icons.check_circle
                              : Icons.shopping_cart,
                        ),
                        label: Text(
                          isInCart ? "Already in Cart" : "Add to Cart",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isInCart ? Colors.grey : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/payment');
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text("Buy"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
