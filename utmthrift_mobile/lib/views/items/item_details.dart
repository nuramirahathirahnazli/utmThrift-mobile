// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/item_model.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';

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

  
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ItemViewModel>(context, listen: false);
    _itemFuture = viewModel.fetchItemDetails(widget.itemId);
    _cartViewModel = Provider.of<CartViewModel>(context, listen: false);
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

          print('Item details: $item');

          // Extract images list safely
          final List<dynamic> imagesDynamic = item['images'] ?? [];
          final List<String> images = imagesDynamic.map((e) => e.toString()).toList();

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
                  Text(
                    'Seller: ${item['seller']?['name'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16),
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
                  const SizedBox(height: 100), // Extra space for bottom buttons
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>?>(
        future: _itemFuture,
        builder: (context, snapshot) {
          // Disable buttons if no data loaded yet
          final isDataAvailable = snapshot.hasData && snapshot.data != null;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chat Seller Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Chat with seller feature coming soon.")),
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

                // Add to Cart Button
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

                    // Create an Item instance to check against the cart
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
                    );

                    final isInCart = cartViewModel.isItemInCart(item);

                    return Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isInCart
                            ? null
                            : () => _addToCart(snapshot.data!),
                        icon: Icon(
                          isInCart ? Icons.check_circle : Icons.shopping_cart,
                        ),
                        label: Text(
                          isInCart ? "Already in Cart" : "Add to Cart",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart ? Colors.grey : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                // Buy Now Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/payment'); // Adjust route as needed
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