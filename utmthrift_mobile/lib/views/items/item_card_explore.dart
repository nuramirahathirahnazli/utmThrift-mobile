// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/items/item_details.dart';

class ItemCardExplore extends StatelessWidget {
  final int itemId;
  final String imageUrl;
  final String name;
  final double price;
  final String seller;
  final String condition;

  const ItemCardExplore({
    Key? key,
    required this.itemId,
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
              itemId: itemId,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: SizedBox(
          height: 220, // tweak this height based on your layout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                      Text("RM ${price.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.orange, fontSize: 14)),
                      Text(condition,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(), // pushes the Row to the bottom
                      Row(
                        children: [
                          const Icon(Icons.person, size: 12, color: Colors.grey),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(seller,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
