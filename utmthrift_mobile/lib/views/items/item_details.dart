import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product["name"])),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(product["image"], width: 200, height: 200),
          SizedBox(height: 20),
          Text(product["name"], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("\$${product["price"]}", style: TextStyle(fontSize: 20, color: Colors.green)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add to cart logic here
            },
            child: Text("Add to Cart"),
          ),
        ],
      ),
    );
  }
}
