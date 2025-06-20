// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/sellersale_model.dart';
import 'package:utmthrift_mobile/views/seller/seller_fullScreenImage_view_track_details_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class SellerSaleDetailPage extends StatelessWidget {
  final SellerSale sale;

  const SellerSaleDetailPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final total = sale.price * sale.quantity;

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text('Sale Details',
            style: TextStyle(color: AppColors.color10)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.color1, // Orange
        iconTheme: const IconThemeData(color: AppColors.color10), // Black icons
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Card
            Card(
              elevation: 2,
              color: AppColors.color12, // Light Yellow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.color3.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag, 
                            color: AppColors.color2, size: 24), // Dark Pink
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(sale.itemName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.color10)), // Black
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Details Row
                    _buildDetailRow(
                      icon: Icons.attach_money,
                      iconColor: AppColors.color6, // Green
                      title: "Total",
                      value: "RM ${total.toStringAsFixed(2)}",
                    ),
                    const SizedBox(height: 12),
                    
                    _buildDetailRow(
                      icon: Icons.credit_card,
                      iconColor: AppColors.color7, // Blue
                      title: "Payment Method",
                      value: sale.paymentMethod,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      iconColor: AppColors.color2, // Dark Pink
                      title: "Date",
                      value: sale.createdAt.toLocal().toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Receipt Section
            if (sale.paymentMethod.toLowerCase().trim() == "qr code" && 
                sale.receiptImage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Receipt Image",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.color10)), // Black
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.color3.withOpacity(0.3)), // Soft Pink
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullscreenImageViewer(imageUrl: sale.receiptImage!),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              sale.receiptImage!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 250,
                                  color: AppColors.color9,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 250,
                                  color: AppColors.color11,
                                  child: const Center(child: Text('Failed to load image')),
                                );
                              },
                            ),
                          ),
                        ),

                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.color2, // Dark Pink
                    fontSize: 14)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: AppColors.color10, // Black
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}