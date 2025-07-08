// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/views/seller/seller_item_details_page.dart'; 

class MyItemsPage extends StatefulWidget {
  const MyItemsPage({super.key});

  @override
  State<MyItemsPage> createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch seller items when page loads
    Future.microtask(() =>
        Provider.of<ItemViewModel>(context, listen: false).fetchSellerItems());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemViewModel>(
      builder: (context, itemVM, child) {
        if (itemVM.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('My Items'),
              automaticallyImplyLeading: false,
              elevation: 0,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (itemVM.errorMessage.isNotEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Items'),
              automaticallyImplyLeading: false,
              elevation: 0,),
            body: Center(child: Text(itemVM.errorMessage)),
          );
        }

        if (itemVM.sellerItems.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Items'),
              automaticallyImplyLeading: false,
              elevation: 0,),
            body: const Center(child: Text('No items uploaded yet.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Items'),
            automaticallyImplyLeading: false,
            elevation: 0,),
          body: RefreshIndicator(
            onRefresh: () async {
              await Provider.of<ItemViewModel>(context, listen: false).fetchSellerItems();
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: itemVM.sellerItems.length,
              itemBuilder: (context, index) {
                final item = itemVM.sellerItems[index];
                return GestureDetector(
                  onTap: () {
                    print("Tapped item ID: ${item.id}"); // debug print
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailsPage(itemId: item.id),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: item.imageUrls.isNotEmpty
                                ? Image.network(
                                    item.imageUrls.first,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image),
                                  )
                                : const Icon(Icons.image_not_supported),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "RM ${item.price.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );

      },
    );
  }
}
