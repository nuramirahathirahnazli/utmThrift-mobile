// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/services/cart_service.dart';
import 'package:utmthrift_mobile/services/order_service.dart';
import 'package:utmthrift_mobile/viewmodels/chatmessage_viewmodel.dart';
import 'package:utmthrift_mobile/views/chat/chat_screen.dart';

class MeetWithSellerPage extends StatelessWidget {
  final int sellerId;
  final String sellerName;
  final int currentUserId;
  final int? itemId; // Added for item context

  const MeetWithSellerPage({
    super.key,
    required this.sellerId,
    required this.sellerName,
    required this.currentUserId,
    this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Arrange Meeting with $sellerName"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(context),
              const SizedBox(height: 24),
              _buildInstructionsCard(context),
              const Spacer(),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Meet-Up Arrangement",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          "Confirm meeting details with $sellerName",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              "How it works:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildInstructionStep("1. Confirm to open chat with seller"),
            _buildInstructionStep("2. Agree on meeting time and place"),
            _buildInstructionStep("3. Complete payment during meet-up"),
            _buildInstructionStep("4. Mark as completed after transaction"),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Back"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () => _handleConfirmation(context),
            child: const Text(
              "Confirm & Chat",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleConfirmation(BuildContext context) async {
  try {
    // Debug prints for checking null or invalid values
    print('DEBUG >> sellerId: $sellerId');
    print('DEBUG >> sellerName: $sellerName');
    print('DEBUG >> currentUserId: $currentUserId');
    print('DEBUG >> itemId: $itemId');

    if (itemId == null) {
      // Show error if itemId is null since you're forcing itemId! in the call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item ID is null. Cannot proceed.")),
      );
      return;
    }

    final success = await OrderService.createMeetUpOrder(
      buyerId: currentUserId,
      itemId: itemId!,
      sellerId: sellerId,
      quantity: 1,
    );

    if (success) {
      final cartService = CartService();
      await cartService.removeItemFromCart(itemId!);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ChatMessageViewModel(),
            child: ChatScreen(
              sellerId: sellerId,
              sellerName: sellerName,
              currentUserId: currentUserId,
              itemId: itemId,
              initialMessage: "Hi, I'd like to arrange meet-up for payment",
              paymentMethod: 'Meet Up',
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create order. Please try again.")),
      );
    }
  } catch (e) {
    print('DEBUG >> Exception: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: $e")),
    );
  }
}

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Meet-Up Help"),
        content: const Text(
          "This method requires you to physically meet the seller to complete the transaction. "
          "Always choose public places and verify the item before payment.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }
}
