// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:utmthrift_mobile/models/item_model.dart';
import 'package:utmthrift_mobile/models/itemcart_model.dart';
import 'package:utmthrift_mobile/services/cart_service.dart';

class CartViewModel with ChangeNotifier {
  final CartService _cartService = CartService();

  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;
  
  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }


  double get totalAmount {
    return _items.values.fold(
      0.0, 
      (sum, item) => sum + item.price * item.quantity);
  }

  /// Load from backend
  Future<void> loadCartItems() async {
    try {
      final cartItems = await _cartService.fetchCartItems();
      print('Fetched cart items: $cartItems');
      _items.clear();
      for (var cartItem in cartItems) {
        _items[cartItem.itemId] = cartItem;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  /// Initialize cart 
  bool isItemInCart(Item item) {
    return _items.containsKey(item.id);
  }

  /// Add to cart
  Future<bool> addItem(Item item, {int quantity = 1}) async {
    final success = await _cartService.addItemToCart(item.id);
    if (!success) return false;

    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity += quantity;
    } else {
      _items[item.id] = CartItem(
        itemId: item.id,
        name: item.name,
        price: item.price,
        quantity: quantity, 
      );
    }
    notifyListeners();
    return true;
  }

  /// Update quantity
  Future<void> updateItemQuantity(int itemId, int newQuantity) async {
    final success = await _cartService.updateCartItem(itemId, newQuantity);
    if (success && _items.containsKey(itemId)) {
      _items[itemId]!.quantity = newQuantity;
      notifyListeners();
    }
  }

  /// Remove item
  Future<void> removeItem(int itemId) async {
    final success = await _cartService.removeCartItem(itemId);
    if (success) {
      _items.remove(itemId);
      notifyListeners();
    }
  }

  /// Checkout
  Future<bool> checkout() async {
    final success = await _cartService.checkout();
    if (success) {
      _items.clear();
      notifyListeners();
    }
    return success;
  }

  /// Clear cart locally
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}