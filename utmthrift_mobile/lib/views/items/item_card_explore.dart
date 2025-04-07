// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/items/item_details.dart';

class ItemCardExplore extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final String seller;
  final String condition;

  const ItemCardExplore({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.seller,
    required this.condition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(
              imageUrl: imageUrl,
              name: name,
              price: price,
              seller: seller,
              condition: condition,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text("RM ${price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.orange, fontSize: 14)),
                  Text(condition, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 12, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(seller, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
