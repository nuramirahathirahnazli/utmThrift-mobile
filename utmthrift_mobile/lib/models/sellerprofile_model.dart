import 'review_model.dart';
import 'sellerinfo_model.dart';

class SellerReviewProfileData {
  final double averageRating;
  final List<Review> reviews;
  final SellerInfo seller;

  SellerReviewProfileData({
    required this.averageRating,
    required this.reviews,
    required this.seller,
  });

  factory SellerReviewProfileData.fromJson(Map<String, dynamic> json) {
    return SellerReviewProfileData(
      averageRating: double.tryParse(json['average_rating'].toString()) ?? 0.0,
      reviews: (json['reviews'] as List)
          .map((r) => Review.fromJson(r))
          .toList(),
      seller: SellerInfo.fromJson(json['seller']),
    );
  }
}
