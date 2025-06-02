import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/itemcart_model.dart';


class CheckoutDetailsPage extends StatelessWidget {
  final CartItem item;

  const CheckoutDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(item.imageUrl as String, height: 150),
            const SizedBox(height: 10),
            Text(item.name, style: const TextStyle(fontSize: 20)),
            Text("Price: RM ${item.price.toStringAsFixed(2)}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // implement payment or place order logic
              },
              child: const Text("Confirm and Pay"),
            )
          ],
        ),
      ),
    );
  }
}
