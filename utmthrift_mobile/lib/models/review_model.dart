class Review {
  final int id;
  final int buyerId;
  final int sellerId;
  final int rating;
  final String? comment;
  final String createdAt;
  final String? buyerName;

  Review({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.buyerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: int.tryParse(json['id'].toString()) ?? 0,
      buyerId: int.tryParse(json['buyer_id'].toString()) ?? 0,
      sellerId: int.tryParse(json['seller_id'].toString()) ?? 0,
      rating: int.tryParse(json['rating'].toString()) ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'].toString(),
      buyerName: json['buyer_name'],
    );
  }

}
