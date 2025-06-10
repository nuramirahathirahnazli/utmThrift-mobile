// ignore_for_file: avoid_print

import 'dart:convert';

class Item {
  final int id;
  final String name;
  final String description;
  final double price;
  final String condition;
  final List<String> imageUrls;
  final String category; 
  final String? seller; 
  final int sellerId;
  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.condition,
    required this.imageUrls,
    required this.category,
    required this.seller,
    required this.sellerId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    print('DEBUG parsing item: $json');

    final imagesData = json['image']; 
    print('DEBUG imagesData type: ${imagesData.runtimeType}, value: $imagesData');
    
    List<String> images = [];

    if (imagesData == null) {
      images = [];
    } else if (imagesData is String) {
      try {
        images = (jsonDecode(imagesData) as List<dynamic>).cast<String>();
      } catch (e) {
        images = [];
      }
    } else if (imagesData is List) {
      images = List<String>.from(imagesData);
    } else {
      images = [];
    }

    // Extract category name from nested object if present
    String categoryName = 'Unknown';
    if (json['category'] != null && json['category'] is Map<String, dynamic>) {
      categoryName = json['category']['name'] ?? 'Unknown';
    }

    // Extract seller name - UPDATED to match backend response
    String sellerName = json['seller_name'] ?? 'Unknown'; // Direct field access

    // Extract seller ID - UPDATED to match backend response
    int extractedSellerId = 0;
    if (json['seller_id'] != null) {
      extractedSellerId = int.tryParse(json['seller_id'].toString()) ?? 0;
    }

    return Item(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
       condition: json['condition'] ?? '',
      imageUrls: images,
      category: categoryName,
      seller: sellerName,
      sellerId: extractedSellerId,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'condition': condition,
      'images': imageUrls,  
      'category': category, 
      'seller_id': sellerId,
    };
  }
}
