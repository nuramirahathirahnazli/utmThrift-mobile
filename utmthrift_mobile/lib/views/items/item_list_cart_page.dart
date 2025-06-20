// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/itemcart_model.dart';
import 'package:utmthrift_mobile/services/auth_service.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/views/items/item_checkout_details_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cartViewModel = CartViewModel();
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchCart();
  }

  Future<void> _loadUserIdAndFetchCart() async {
    final storedUserId = await AuthService.getCurrentUserId();
    print('Loaded user_id: $storedUserId');

    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
    } else {
      // Optionally show error or redirect to login
      print('User ID not found. Redirecting to login...');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: FutureBuilder<List<CartItem>>(
        future: cartViewModel.fetchCartItems(userId!), // 🧠 Pass userId
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Cart load error: ${snapshot.error}');
            return const Center(child: Text("Error loading cart."));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }

          final cartList = snapshot.data!;

          return ListView.builder(
            itemCount: cartList.length,
            itemBuilder: (context, index) {
              final item = cartList[index];
              print("DEBUG >> Checkout button pressed. sellerId: ${item.sellerId}, sellerName: ${item.sellerName}");
              return Card(
                child: ListTile(
                  leading: item.imageUrl.isNotEmpty
                      ? Image.network(item.imageUrl.first, width: 60)
                      : const Icon(Icons.image_not_supported, size: 60),
                  title: Text(item.name),
                  subtitle: Text("RM ${item.price.toStringAsFixed(2)}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutDetailsPage(
                            item: item),
                        ),
                      );
                    },
                    child: const Text("Checkout Now"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
