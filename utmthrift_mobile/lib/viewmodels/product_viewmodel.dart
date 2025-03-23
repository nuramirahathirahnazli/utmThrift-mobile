import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> getProducts() async {
    _products = await _apiService.fetchProducts();
    notifyListeners();
  }
}
