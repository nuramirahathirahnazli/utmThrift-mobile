// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderHistoryDetailsPage extends StatelessWidget {
  final Order order;

  const OrderHistoryDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final item = order.item;
    final isPending = order.status.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text('Order Details',
            style: TextStyle(color: AppColors.color10)),
        backgroundColor: AppColors.color1,
        iconTheme: const IconThemeData(color: AppColors.color10),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Card
            Card(
              color: AppColors.color12,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item?.name ?? 'Unknown Item',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.color10)),
                    const SizedBox(height: 8),
                    if (item?.imageUrls != null && item!.imageUrls.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: item.imageUrls.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrls[index],
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Order Details Card
            Card(
              color: AppColors.color5,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Price',
                        'RM ${item?.price.toStringAsFixed(2) ?? '0.00'}'),
                    _buildDetailRow('Condition', item?.condition ?? 'Unknown'),
                    _buildDetailRow(
                        'Category', item?.category ?? 'Unknown'),
                    _buildDetailRow(
                        'Payment Method', order.paymentMethod),
                    _buildDetailRow('Status', order.status,
                        isHighlighted: true,
                        highlightColor: isPending
                            ? AppColors.color4
                            : const Color.fromARGB(153, 43, 92, 6)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (isPending)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showConfirmDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.color1,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Mark as Received',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.color10)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlighted = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.color10,
                  fontSize: 16)),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 16,
                    color: isHighlighted
                        ? highlightColor ?? AppColors.color10
                        : AppColors.color10)),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.base,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Confirm Order',
            style: TextStyle(color: AppColors.color10)),
        content: const Text('Are you sure you received this item?',
            style: TextStyle(color: AppColors.color10)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.color4)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _confirmOrder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.color1,
            ),
            child: const Text('Confirm',
                style: TextStyle(color: AppColors.color10)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context) async {
    final success = await OrderService.confirmOrder(order.id);

    if (success) {
      _showSuccessDialog(context);
    } else {
      _showErrorDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.base,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Success',
            style: TextStyle(color: AppColors.color6)),
        content: const Text('Order marked as completed.',
            style: TextStyle(color: AppColors.color10)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('OK',
                style: TextStyle(color: AppColors.color1)),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.base,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Error',
            style: TextStyle(color: AppColors.color4)),
        content: const Text('Failed to update order status.',
            style: TextStyle(color: AppColors.color10)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: AppColors.color1)),
          )
        ],
      ),
    );
  }
}