class ChatPartner {
  final int sellerId;
  final String name;
  final int unreadCount;
  final String? lastMessage;

  ChatPartner({
    required this.sellerId,
    required this.name,
    this.unreadCount = 0,
    this.lastMessage,
  });

  factory ChatPartner.fromJson(Map<String, dynamic> json) {
    return ChatPartner(
      sellerId: json['sellerId'] as int,
      name: json['name'] ?? 'Unknown',
      unreadCount: json['unreadCount'] ?? 0,
      lastMessage: json['lastMessage'] ?? json['last_message'], // accept both
    );
  }
}
