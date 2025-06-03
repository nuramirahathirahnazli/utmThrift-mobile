class ChatPartner {
  final int? sellerId;
  final int? itemId;
  final String itemName;
  final String name;
  final int unreadCount;

  ChatPartner({
    this.sellerId,
    this.itemId,
    required this.itemName,
    required this.name,
    this.unreadCount = 0,  // default to 0 if not provided
  });

  factory ChatPartner.fromJson(Map<String, dynamic> json) {
    return ChatPartner(
      sellerId: json['sellerId'] as int?,  // nullable int
      itemId: json['itemId'] as int?,      // nullable int
      itemName: json['itemName'] ?? 'Unknown Item',
      name: json['name'] ?? 'Unknown',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
