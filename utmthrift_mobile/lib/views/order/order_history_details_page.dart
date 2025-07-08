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
    final statusColor = _getStatusColor(order.status);

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: AppColors.color10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.color2, // Changed to maroon color
        iconTheme: const IconThemeData(color: AppColors.base),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppColors.color12,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item?.name ?? 'Unknown Item',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.color10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (item?.imageUrls != null && item!.imageUrls.isNotEmpty)
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: PageView.builder(
                            itemCount: item.imageUrls.length,
                            itemBuilder: (context, index) => Image.network(
                              item.imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Order Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppColors.color5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      Icons.attach_money,
                      'Price',
                      'RM ${item?.price.toStringAsFixed(2) ?? '0.00'}',
                    ),
                    _buildDetailRow(
                      Icons.star,
                      'Condition',
                      item?.condition ?? 'Unknown',
                    ),
                    _buildDetailRow(
                      Icons.category,
                      'Category',
                      item?.category ?? 'Unknown',
                    ),
                    _buildDetailRow(
                      Icons.payment,
                      'Payment Method',
                      order.paymentMethod,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Status: ${order.status.toUpperCase()}',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (isPending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showConfirmDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color2, // Maroon button
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Mark as Received',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.base, // Light text on dark button
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.color2, // Maroon icons
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.color10.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.color10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green[800]!;
      case 'pending':
        return Colors.orange[800]!;
      case 'cancelled':
        return Colors.red[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.base,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Confirm Order',
          style: TextStyle(
            color: AppColors.color10,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you received this item?',
          style: TextStyle(color: AppColors.color10),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.color4),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _confirmOrder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.color2, // Maroon button
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: AppColors.base),
            ),
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
        title: Text(
          'Success',
          style: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Order marked as completed.',
          style: TextStyle(color: AppColors.color10),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.color2),
            ),
          ),
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
        title: Text(
          'Error',
          style: TextStyle(
            color: Colors.red[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Failed to update order status.',
          style: TextStyle(color: AppColors.color10),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.color2),
            ),
          ),
        ],
      ),
    );
  }
}