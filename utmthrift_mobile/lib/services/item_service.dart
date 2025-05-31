// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:utmthrift_mobile/models/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:http_parser/http_parser.dart'; // for MediaType

class ItemService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Fetch item categories with authorization
  Future<List<dynamic>> fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    final response = await http.get(
      Uri.parse('$baseUrl/items/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body.containsKey('itemcategories')) {
        return body['itemcategories'];
      } else {
        throw Exception("Invalid response format: Missing 'itemcategories' key.");
      }
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  // Fetch all items without any filters
  Future<List<Item>> fetchAllItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/items'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      List<dynamic> itemsList = body.containsKey('data') ? body['data'] : body['items'];
      return itemsList.map((e) => Item.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load all items');
    }
  }

  //Fetch latest 20 items for user homescreen purpose
  static Future<List<Item>> fetchLatestItems({int limit = 20}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/items?limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);

      if (body.containsKey('data')) {
        List<dynamic> itemsList = body['data'];
        return itemsList.map((e) => Item.fromJson(e)).toList();
      } else {
        throw Exception("Invalid response format: Missing 'items' key.");
      }
    } else {
      throw Exception('Failed to load latest items');
    }
  }

  //For explore page
  Future<List<Item>> fetchFilteredItems({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? condition,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final Map<String, String> queryParams = {};
    if (search != null) queryParams['search'] = search;
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (condition != null) queryParams['condition'] = condition;

    final uri = Uri.parse('$baseUrl/items').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      if (body.containsKey('data')) {
        List<dynamic> itemsList = body['data'];
        return itemsList.map((e) => Item.fromJson(e)).toList();
      } else {
        throw Exception("Missing 'data' in response.");
      }
    } else {
      throw Exception('Failed to load items');
    }
  }

  // Fetch item details by item ID
  Future<Map<String, dynamic>> fetchItemDetails(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) throw Exception("User is not authenticated");

    final response = await http.get(
      Uri.parse('$baseUrl/buyer/items/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final item = data['item'];

        //Handle images
        final List<dynamic> imagesDynamic = item['images'] ?? [];
        final List<String> images = imagesDynamic.map((e) => e.toString()).toList();
        item['images'] = images;
        
        return item;
      } else {
        throw Exception('Failed to fetch item: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load item');
    }
  }

  // Fetch favorite items for a user
  Future<Set<int>> fetchFavoriteItemIds(int userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token: $token");

      if (token == null) throw Exception("User is not authenticated");

      print('Fetching favorites for userId: $userId');
      final response = await http.get(Uri.parse('$baseUrl/item/favourites'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('GET response status: ${response.statusCode}');
      print('GET response body: ${response.body}');
      

      if (response.statusCode == 200) {
      final List<dynamic> favorites = jsonDecode(response.body);
      // Explicitly cast to Set<int>
      return favorites.map<int>((fav) => fav['id'] as int).toSet();
    }
    return <int>{}; // Return empty Set<int>
  } catch (e) {
    print('Error fetching favorites: $e');
    return <int>{}; // Return empty Set<int>
  }
}

  // Add favorite item for a user
  Future<bool> addFavorite(int userId, int itemId) async {
    
    print('Toggling favorite for userId: $userId, itemId: $itemId');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) throw Exception("User is not authenticated");

    final response = await http.post(
      Uri.parse('$baseUrl/item/$itemId/toggle-favourite'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );  

    print('POST response status: ${response.statusCode}');
    print('POST response body: ${response.body}');

    return response.statusCode == 201;
  }

  // Remove favorite item for a user
  Future<bool> removeFavorite(int userId, int itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/remove'),
      body: {
        'user_id': userId.toString(),
        'item_id': itemId.toString(),
      },
    );

    return response.statusCode == 200;
  }


  // Add item
  Future<Item?> addItem({
    required String name,
    required int categoryId,
    required String description,
    required double price,
    required String condition,
    required List<String>? imagePaths, // Mobile
    required List<Uint8List>? imageBytes, // Web
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('$baseUrl/seller/add-item');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

    request.fields['name'] = name;
    request.fields['category_id'] = categoryId.toString();
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['condition'] = condition;

    if (kIsWeb) {
      if (imageBytes != null) {
        for (int i = 0; i < imageBytes.length; i++) {
          request.files.add(http.MultipartFile.fromBytes(
            'images[]',
            imageBytes[i],
            filename: 'image_$i.jpg',
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      }
    } else {
      if (imagePaths != null) {
        for (var path in imagePaths) {
          request.files.add(await http.MultipartFile.fromPath('images[]', path));
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Item.fromJson(data['item']);
    } else {
      print('Add item failed: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to add item');
    }
  }

  // Fetch all items for a seller
  Future<List<Item>> fetchSellerItems(int sellerId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception("User is not authenticated");

      final response = await http.get(
        Uri.parse('$baseUrl/seller/$sellerId/items'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> itemsJson = body['items'];
        return itemsJson.map((json) => Item.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load seller items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching seller items: $e');
    }
  }

  // Update item
  Future<bool> updateItem({
    required int itemId,
    required String name,
    required String description,
    required double price,
    required String condition,
    required int categoryId,
    List<XFile>? images,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No auth token found.');

    final url = Uri.parse('$baseUrl/seller/update-items/$itemId');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..fields['name'] = name
      ..fields['description'] = description
      ..fields['price'] = price.toString()
      ..fields['condition'] = condition
      ..fields['category_id'] = categoryId.toString();

    if (images != null) {
      if (kIsWeb) {
        // Web implementation
        for (var image in images) {
          final bytes = await image.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'images[]',
            bytes,
            filename: 'image_${images.indexOf(image)}.jpg',
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      } else {
        // Mobile implementation
        for (var image in images) {
          request.files.add(await http.MultipartFile.fromPath(
            'images[]', 
            image.path
          ));
        }
      }
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Item updated successfully: $responseBody');
        return true;
      } else {
        print('Update failed: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error during update: $e');
      return false;
    }
  }

  // Delete item
  Future<bool> deleteItem(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No auth token found.');

    final response = await http.delete(
      Uri.parse('$baseUrl/seller/delete-item/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Delete item failed: ${response.statusCode} - ${response.body}');
      return false;
    }
  }
}
