import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/sellersale_model.dart';
import 'package:utmthrift_mobile/views/seller/seller_fullScreenImage_view_track_details_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class SellerSaleDetailPage extends StatelessWidget {
  final SellerSale sale;
  final Color _darkerGreen = const Color(0xFF1B5E20);

  const SellerSaleDetailPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final total = sale.price * sale.quantity;

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          'Sale Details',
          style: TextStyle(
            color: AppColors.base,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.color2,
        iconTheme: const IconThemeData(color: AppColors.base),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Card
            Card(
              elevation: 0,
              color: AppColors.color12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppColors.color2.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.color2.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: AppColors.color2,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            sale.itemName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.color10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Details Rows
                    _buildDetailRow(
                      icon: Icons.attach_money,
                      iconColor: _darkerGreen,
                      title: "Total Amount",
                      value: "RM ${total.toStringAsFixed(2)}",
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      icon: Icons.credit_card,
                      iconColor: AppColors.color7,
                      title: "Payment Method",
                      value: sale.paymentMethod,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      iconColor: AppColors.color2,
                      title: "Transaction Date",
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
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Payment Receipt",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.color10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullscreenImageViewer(imageUrl: sale.receiptImage!),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppColors.color2.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.color3.withOpacity(0.2),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                sale.receiptImage!,
                                height: 280,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 280,
                                    color: AppColors.color9,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.color2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 280,
                                    color: AppColors.color11,
                                    child: const Center(
                                      child: Text(
                                        'Failed to load receipt image',
                                        style: TextStyle(color: AppColors.color10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Tap to view full screen',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.color10.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.color10,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}