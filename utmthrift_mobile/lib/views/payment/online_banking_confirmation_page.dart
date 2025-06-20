// ignore_for_file: use_build_context_synchronously, unused_import, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:utmthrift_mobile/models/itemcart_model.dart';
import 'package:utmthrift_mobile/models/user_model.dart';
import 'package:utmthrift_mobile/services/order_service.dart';
import 'package:utmthrift_mobile/viewmodels/payment_viewmodel.dart';
import 'package:utmthrift_mobile/views/payment/payment_webview_page.dart';

class PaymentConfirmationPage extends StatelessWidget {
  final CartItem item;
  final UserModel user;

  const PaymentConfirmationPage({super.key, required this.item, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Payment")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Confirmation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Item: ${item.name}"),
            Text("Total Amount: RM ${item.price.toStringAsFixed(2)}"),
            const SizedBox(height: 20),
            const Text(
              "By clicking proceed, you agree to complete this transaction using Online Banking and understand that the payment is non-refundable.",
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                print("[Payment] Starting order creation...");
                
                final orderId = await OrderService.createOrder(
                  buyerId: user.id,
                  itemId: item.itemId,
                  sellerId: item.sellerId,
                  quantity: 1,
                  paymentMethod: 'Online Banking',
                );

                if (orderId == null) {
                  print("[Payment] Order creation failed.");
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Order creation failed. Please try again."),
                  ));
                  return;
                }

                print("[Payment] Order created successfully. Order ID: $orderId");

                final paymentViewModel = Provider.of<PaymentViewModel>(context, listen: false);
                final billUrl = await paymentViewModel.initiatePayment(
                  amount: item.price,
                  name: user.name,
                  email: user.email,
                  phone: user.contact ?? '',
                  description: "Payment for ${item.name}",
                  orderId: orderId,
                );

                print("[Payment] Received Bill URL: $billUrl");

                if (billUrl != null) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ToyyibPayScreen(
                        paymentUrl: billUrl,
                        orderId: orderId,
                        onPaymentComplete: (result) {
                          // This handles the payment result
                          _handlePaymentResult(context, result, orderId.toString());
                        },
                      ),
                    ),
                  );
                  
                  // For iOS, you might need to handle the result here as well
                  if (result != null) {
                    _handlePaymentResult(context, result, orderId.toString());
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Failed to get payment URL."),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, 
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Proceed to Payment", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePaymentResult(BuildContext context, Map<String, dynamic> result, String orderId) {
    final status = result['status'];
    
    if (status == '1') {
      // Payment successful
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Payment successful!'),
      ));
      // You might want to navigate to a success screen or refresh the order status
    } else {
      // Payment failed
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Payment failed. Please try again.'),
      ));
    }
  }
}
