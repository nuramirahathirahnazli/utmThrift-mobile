class Review {
  final int id;
  final int buyerId;
  final int sellerId;
  final int rating;
  final String? comment;
  final String createdAt;

  Review({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
    );
  }
}
