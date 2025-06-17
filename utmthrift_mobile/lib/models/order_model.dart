// ignore_for_file: avoid_print

import 'package:utmthrift_mobile/models/item_model.dart';

class Order {
  final int id;
  final String status;
  final String paymentMethod;
  final Item? item;
  final bool alreadyReviewed;

  Order({
    required this.id,
    required this.status,
    required this.paymentMethod,
    this.item,
    required this.alreadyReviewed,
    
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    print('DEBUG >> Raw Order JSON: $json');

    final itemJson = json['item'];
    Item? parsedItem;
    if (itemJson != null) {
      parsedItem = Item.fromJson(itemJson);
    } else {
      print('WARNING >> item is null for order id: ${json['id']}');
    }

    return Order(
      id: json['id'] ?? -1,
      status: json['order_status'] ?? 'Unknown Status',
      paymentMethod: json['payment_method'] ?? 'Unknown Method',
      item: parsedItem,
      alreadyReviewed: json['already_reviewed'] ?? false,
    );
  }
}