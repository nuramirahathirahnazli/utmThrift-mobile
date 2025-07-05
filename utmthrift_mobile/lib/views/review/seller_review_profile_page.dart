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
        title: const Text(
          'Seller Profile',
          style: TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.color2, // Maroon app bar
        iconTheme: const IconThemeData(color: AppColors.base),
        elevation: 0,
      ),
      body: FutureBuilder<SellerReviewProfileData>(
        future: SellerService.getSellerProfile(sellerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.color2),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading profile",
                style: TextStyle(
                  color: AppColors.color8, // Red error text
                  fontSize: 16,
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final reviews = data.reviews;
          final seller = data.seller;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seller Rating Card
                Card(
                  color: AppColors.color12, // Light yellow background
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.color2.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: AppColors.color1, // Orange star
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Average Rating",
                              style: TextStyle(
                                color: AppColors.color10.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              data.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.color2, // Maroon text
                              ),
                            ),
                            Text(
                              "${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}",
                              style: TextStyle(
                                color: AppColors.color10.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Seller Information Card
                Card(
                  color: AppColors.color12, // Light yellow background
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.store_outlined,
                          label: "Store Name",
                          value: seller.storeName ?? 'Not provided',
                        ),
                        const Divider(height: 20, color: AppColors.color3),
                        _buildInfoRow(
                          icon: Icons.person_outline,
                          label: "Seller Name",
                          value: seller.name ?? 'Not provided',
                        ),
                        const Divider(height: 20, color: AppColors.color3),
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: "Contact",
                          value: seller.contact ?? 'Not provided',
                        ),
                        const Divider(height: 20, color: AppColors.color3),
                        _buildInfoRow(
                          icon: Icons.work_outline,
                          label: "Role",
                          value: seller.userRole ?? 'Not provided',
                        ),
                        const Divider(height: 20, color: AppColors.color3),
                        _buildInfoRow(
                          icon: Icons.school_outlined,
                          label: "Faculty",
                          value: seller.faculty ?? 'Not provided',
                        ),
                        const Divider(height: 20, color: AppColors.color3),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: "Location",
                          value: seller.location ?? 'Not provided',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Reviews Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Buyer Reviews",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color2, // Maroon text
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  color: AppColors.color3.withOpacity(0.5),
                  thickness: 1,
                ),
                const SizedBox(height: 8),

                // Reviews List
                if (reviews.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.reviews_outlined,
                            size: 50,
                            color: AppColors.color3, // Light pink icon
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No reviews yet",
                            style: TextStyle(
                              color: AppColors.color10.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: reviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Card(
                        color: AppColors.color11, // Light pink background
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.color2, // Maroon
                                    child: Text(
                                      review.buyerName?[0] ?? '?',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.buyerName ?? 'User #${review.buyerId}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.color10,
                                          ),
                                        ),
                                        Text(
                                          review.createdAt.split(' ')[0],
                                          style: TextStyle(
                                            color: AppColors.color10.withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: AppColors.color1, // Orange star
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        review.rating.toString(),
                                        style: const TextStyle(
                                          color: AppColors.color10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                review.comment ?? "No comment provided",
                                style: TextStyle(
                                  color: AppColors.color10.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.color2, // Maroon icon
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.color10.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.color10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}