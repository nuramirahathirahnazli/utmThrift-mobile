
class CartItem {
  final int itemId;
  final String name;
  final double price;
  final List<String> imageUrl;
  late final int quantity;

  CartItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'images': imageUrl,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    var imagesFromJson = json['images']; 

    List<String> imageUrls = [];

    if (imagesFromJson == null) {
      imageUrls = [];
    } else if (imagesFromJson is String) {
      // If it is a single string, convert it to a list with one element
      imageUrls = [imagesFromJson];
    } else if (imagesFromJson is List) {
      // If it is a List, ensure each item is a string
      imageUrls = imagesFromJson.map((e) => e.toString()).toList();
    } else {
      // If unexpected type, fallback to empty list or handle as needed
      imageUrls = [];
    }

    return CartItem(
      itemId: json['item_id'] ?? 0,                 // <-- fix key here
      name: json['item_name'] ?? 'Unknown',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: json['quantity'] ?? 1,
      imageUrl: imageUrls,
    );
  }



}
