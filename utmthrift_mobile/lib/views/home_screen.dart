import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/items/item_details.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {"name": "Laptop", "price": 1000, "image": "https://via.placeholder.com/150"},
    {"name": "Smartphone", "price": 500, "image": "https://via.placeholder.com/150"},
    {"name": "Headphones", "price": 100, "image": "https://via.placeholder.com/150"},
  ];

   HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UTMThrift Marketplace")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            child: ListTile(
              leading: Image.network(product["image"], width: 50, height: 50),
              title: Text(product["name"]),
              subtitle: Text("\$${product["price"]}"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
