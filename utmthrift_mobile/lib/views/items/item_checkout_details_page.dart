// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/itemcart_model.dart';
import 'package:utmthrift_mobile/services/user_service.dart';
import 'package:utmthrift_mobile/services/auth_service.dart';
import 'package:utmthrift_mobile/models/user_model.dart';
import 'package:utmthrift_mobile/views/payment/meet_with_seller_page.dart';

class CheckoutDetailsPage extends StatefulWidget {
  final CartItem item;

  const CheckoutDetailsPage({super.key, required this.item});

  @override
  State<CheckoutDetailsPage> createState() => _CheckoutDetailsPageState();
}

class _CheckoutDetailsPageState extends State<CheckoutDetailsPage> {
  UserModel? _user;
  String _selectedPayment = "QR Code";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final token = await AuthService.getToken();
    if (token != null) {
      final userData = await UserService.getUserProfile(token);
      setState(() {
        _user = userData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout Details")),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  /// ============ ITEM IMAGE ============
                  widget.item.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.item.imageUrl.first,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                          },
                        )
                      : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),

                  /// ============ ITEM DETAILS ============
                  Text(widget.item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Price: RM ${widget.item.price.toStringAsFixed(2)}"),
                  const SizedBox(height: 20),

                  /// ============ USER DETAILS ============
                  const Text("Buyer Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Name: ${_user!.name}"),
                  Text("Contact: ${_user!.contact}"),
                  Text("Location: ${_user!.location}"),
                  const Divider(height: 30),

                  /// ============ PAYMENT METHOD ============
                  const Text("Select Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  RadioListTile(
                    title: const Text("QR Code"),
                    value: "QR Code",
                    groupValue: _selectedPayment,
                    onChanged: (value) => setState(() => _selectedPayment = value!),
                  ),
                  RadioListTile(
                    title: const Text("Online Banking"),
                    value: "Online Banking",
                    groupValue: _selectedPayment,
                    onChanged: (value) => setState(() => _selectedPayment = value!),
                  ),
                  RadioListTile(
                    title: const Text("Meet with Seller"),
                    value: "Meet with Seller",
                    groupValue: _selectedPayment,
                    onChanged: (value) => setState(() => _selectedPayment = value!),
                  ),
                  const Divider(height: 30),

                  /// ============ TOTAL ============
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("RM ${widget.item.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// ============ PLACE ORDER BUTTON ============
                  ElevatedButton(
                    onPressed: () {
                      print("Placing order with payment method: $_selectedPayment");
                      print("DEBUG >> sellerId: ${widget.item.sellerId}, sellerName: ${widget.item.sellerName}, currentUserId: ${_user!.id}");

                      if (_selectedPayment == "Meet with Seller") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeetWithSellerPage(
                              sellerId: widget.item.sellerId,  
                              sellerName: widget.item.sellerName,
                              currentUserId: _user!.id, 
                              itemId: widget.item.itemId,

                            ),
                          ),
                        );
                      } else {
                        // Handle other payment options like QR Code / Online Banking
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text("Place Order", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}
