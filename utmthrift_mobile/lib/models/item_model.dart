// ignore_for_file: avoid_print

import 'dart:convert';

class Item {
  final int id;
  final String name;
  final String description;
  final double price;
  final String condition;
  final List<String> imageUrls;
  final String category; // now storing category name, not ID

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.condition,
    required this.imageUrls,
    required this.category,
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

    return Item(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      condition: json['condition'] as String,
      imageUrls: images,
      category: categoryName,
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
    };
  }
}
