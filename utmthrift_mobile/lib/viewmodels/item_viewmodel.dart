// ignore_for_file: avoid_print, unnecessary_null_comparison,

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utmthrift_mobile/services/item_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/models/item_model.dart';

class ItemViewModel extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  List<dynamic> categories = [];
  List<Item> sellerItems = [];
  bool isLoading = false;
  String errorMessage = '';

  Item? newItem;  // Store the newly added item
  Map<String, dynamic>? itemDetails;  // Store item details fetched from API
  List<String> _images = [];

  List<String> get images => _images;

  set images(List<String> newImages) {
    _images = newImages;
    notifyListeners();
  }

  void updateImages(List<String> newImages) {
    images = newImages;
  }
  
  /// Fetch all item categories from API
  Future<void> fetchCategories() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      categories = await _itemService.fetchCategories();
      print("Fetched categories: $categories");
    } catch (e) {
      errorMessage = e.toString();
      print(errorMessage);
    }

    isLoading = false;
    notifyListeners();
  }

  /// Fetch single item details using item ID
  Future<Map<String, dynamic>?> fetchItemDetails(int id) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      itemDetails = await _itemService.fetchItemDetails(id);
    } catch (e) {
      errorMessage = e.toString();
      itemDetails = null;
    }

    isLoading = false;
    notifyListeners();
    return itemDetails; 
  }


  /// Add a new item
  Future<Item?> addItem({
    required String name,
    required int categoryId,
    required String description,
    required double price,
    required String condition,
    List<String>? imagePaths,      // For mobile local file paths
    List<Uint8List>? imageBytes,   // For web image bytes
  }) async {
      try {
      isLoading = true;
      notifyListeners();

      final item = await _itemService.addItem(
        name: name,
        categoryId: categoryId,
        description: description,
        price: price,
        condition: condition,
        imagePaths: imagePaths,
        imageBytes: imageBytes,
      );

      isLoading = false;
      notifyListeners();

      return item;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Fetch all items for that seller
  Future<void> fetchSellerItems() async {
    isLoading = true;
    errorMessage = '';
    sellerItems = [];
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sellerId = prefs.getInt('user_id');
      if (sellerId == null) {
        throw Exception('Seller ID not found.');
      }
      sellerItems = await _itemService.fetchSellerItems(sellerId);
      errorMessage = '';
    } catch (e) {
      errorMessage = e.toString();
      sellerItems = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateItem({
    required int itemId,
    required String name,
    required String description,
    required double price,
    required String condition,
    required int categoryId,
    List<XFile>? images,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      bool success = await _itemService.updateItem(
        itemId: itemId,
        name: name,
        description: description,
        price: price,
        condition: condition,
        categoryId: categoryId,
        images: images,
      );
      return success;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //Delete item
  Future<bool> deleteItem(int itemId) async {
    isLoading = true;
    notifyListeners();

    try {
      bool success = await _itemService.deleteItem(itemId);
      if (success) {
        sellerItems.removeWhere((item) => item.id == itemId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}