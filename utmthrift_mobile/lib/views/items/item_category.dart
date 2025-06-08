// ignore_for_file: use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/items/item_card_explore.dart';

class CategoryItemsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryItemsScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulated list of items based on category
    List<Map<String, dynamic>> items = [
      if (categoryName == "Shoes") ...[
        {
          "imageUrl": "https://via.placeholder.com/150",
          "name": "Nike Running Shoes",
          "price": 45.0,
          "seller": "shoe_lover",
          "condition": "Like New",
        },
        {
          "imageUrl": "https://via.placeholder.com/150",
          "name": "Adidas Sneakers",
          "price": 50.0,
          "seller": "mirazaki",
          "condition": "Brand New",
        },
      ],
      if (categoryName == "Men's Clothes") ...[
        {
          "imageUrl": "https://via.placeholder.com/150",
          "name": "Black Hoodie",
          "price": 30.0,
          "seller": "danish_mohamed",
          "condition": "Used",
        },
        {
          "imageUrl": "https://via.placeholder.com/150",
          "name": "Leather Jacket",
          "price": 100.0,
          "seller": "fashion_guy",
          "condition": "Brand New",
        },
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: items.isEmpty
          ? const Center(child: Text("No items available in this category."))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ItemCardExplore(
                    imageUrl: items[index]["imageUrl"],
                    name: items[index]["name"],
                    price: items[index]["price"],
                    seller: items[index]["seller"],
                    condition: items[index]["condition"], 
                    itemId: index,
                    isFavorite: false, // placeholder, update with actual logic if needed
                    onFavoriteToggle: () {
                      // placeholder function, update with favorite toggle logic
                      print("Toggled favorite for item ${items[index]["name"]}");
                    },
                  );
                },
              ),
            ),
    );
  }
}
