
class CartItem {
  final int itemId;
  final String name;
  final double price;
  late final int quantity;

  CartItem({
    required this.itemId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final itemData = json['item'];
    return CartItem(
      itemId: json['item_id'],
      name: itemData['name'],
      price: double.parse(itemData['price']),
      quantity: json['quantity'],
    );
  }

}
