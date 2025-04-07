// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product["name"])),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(product["image"], width: 200, height: 200),
          const SizedBox(height: 20),
          Text(product["name"], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("\$${product["price"]}", style: const TextStyle(fontSize: 20, color: Colors.green)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add to cart logic here
            },
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }
}


class ItemDetailsScreen extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final String seller;
  final String condition;

  const ItemDetailsScreen({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.seller,
    required this.condition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Item Name
              Text(
                name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              // Price
              Text(
                "RM ${price.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Condition
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    condition,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Seller Info
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "Seller: $seller",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle Chat with Seller action
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text("Chat Seller"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle Add to Cart action
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Add to Cart"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
