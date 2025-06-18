import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/sellerprofile_model.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import '../../services/seller_service.dart';

class SellerReviewProfilePage extends StatelessWidget {
  final int sellerId;

  const SellerReviewProfilePage({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text('Seller Profile', style: TextStyle(color: AppColors.color10)),
        backgroundColor: AppColors.color1,
        iconTheme: const IconThemeData(color: AppColors.color10),
      ),
      body: FutureBuilder<SellerReviewProfileData>(
        future: SellerService.getSellerProfile(sellerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.color1,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: AppColors.color8),
              ),
            );
          }

          final data = snapshot.data!;
          final reviews = data.reviews;
          final seller = data.seller;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐ Average Rating
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.color12,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppColors.color1),
                      const SizedBox(width: 8),
                      Text(
                        "Average Rating: ${data.averageRating.toStringAsFixed(1)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.color10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🧾 Seller Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.color11,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.store, "Store Name: ${seller.storeName ?? 'Not provided'}"),
                      const Divider(height: 16, color: AppColors.color3),
                      _buildInfoRow(Icons.person, "Name: ${seller.name ?? 'Not provided'}"),
                      const Divider(height: 16, color: AppColors.color3),
                      _buildInfoRow(Icons.phone, "Contact: ${seller.contact ?? 'Not provided'}"),
                      const Divider(height: 16, color: AppColors.color3),
                      _buildInfoRow(Icons.work, "Role: ${seller.userRole ?? 'Not provided'}"),
                      const Divider(height: 16, color: AppColors.color3),
                      _buildInfoRow(Icons.school, "Faculty: ${seller.faculty ?? 'Not provided'}"),
                      const Divider(height: 16, color: AppColors.color3),
                      _buildInfoRow(Icons.location_on, "Location: ${seller.location ?? 'Not provided'}"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🗨️ Reviews
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Buyer Reviews:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color2,
                    ),
                  ),
                ),
                const Divider(color: AppColors.color3, thickness: 1),

                Expanded(
                  child: reviews.isEmpty
                      ? Center(
                          child: Text(
                            "No reviews yet.",
                            style: TextStyle(
                              color: AppColors.color10.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: reviews.length,
                          itemBuilder: (context, i) {
                            final r = reviews[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 2,
                              color: AppColors.color5,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.color2,
                                  child: Text(
                                    r.buyerName?[0] ?? '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  r.buyerName ?? 'User #${r.buyerId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.color10,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 16, color: AppColors.color1),
                                        Text(
                                          " ${r.rating}",
                                          style: const TextStyle(color: AppColors.color10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      r.comment ?? "No comment",
                                      style: const TextStyle(color: AppColors.color10),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  r.createdAt.split(' ')[0],
                                  style: TextStyle(
                                    color: AppColors.color10.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.color2),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.color10),
          ),
        ),
      ],
    );
  }
}