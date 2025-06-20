// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:utmthrift_mobile/views/seller/seller_edit_item_details_page.dart';

class ItemDetailsPage extends StatefulWidget {
  final int itemId;

  const ItemDetailsPage({required this.itemId, super.key});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late Future<Map<String, dynamic>?> _itemFuture;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ItemViewModel>(context, listen: false);
    _itemFuture = viewModel.fetchItemDetails(widget.itemId);
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
      final success = await viewModel.deleteItem(widget.itemId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
          Navigator.of(context).pop(); // Go back to My Items page
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete item')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
        // Use default leading back button to go back
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
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

          print("Fetched item: $item");

          final images = item['images'] is List
              ? List<String>.from(item['images'])
              : [];

          print("Decoded images: $images");

          if (images.isEmpty) {
            print("No images available for this item");
          }

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
                    'Price: \$${num.tryParse(item['price'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                              final imageUrl = Uri.decodeFull(images[index]);
                              print("Loading image from: $imageUrl");

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(
                                  imageUrl,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              );
                            },
                          )
                        : const Center(child: Text("No images available")),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updated = await _itemFuture.then((itemData) {
                    if (itemData != null) {
                      return Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerEditItemDetailsPage(item: itemData),
                        ),
                      );
                    }
                    return Future.value(false);
                  });

                  if (updated == true) {
                    final viewModel = Provider.of<ItemViewModel>(context, listen: false);
                    setState(() {
                      _itemFuture = viewModel.fetchItemDetails(widget.itemId);
                    });
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Item"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deleteItem,
                icon: const Icon(Icons.delete),
                label: const Text("Delete Item"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
