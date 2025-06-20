class SellerSale {
  final int orderId;
  final String itemName;
  final int quantity;
  final double price;
  final String paymentMethod;
  final String? receiptImage;
  final DateTime createdAt;


  SellerSale({
    required this.orderId,
    required this.itemName,
    required this.paymentMethod,
    this.receiptImage,
    required this.createdAt,
    required this.quantity,
    required this.price,
  });

  factory SellerSale.fromJson(Map<String, dynamic> json) {
    return SellerSale(
      orderId: json['order_id'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0.0, // ✅ Safely parse string to double
      paymentMethod: json['payment_method'],
      receiptImage: json['receipt_image'],
      createdAt: DateTime.parse(json['created_at']), // ✅ Convert String to DateTime
    );
  }

}
