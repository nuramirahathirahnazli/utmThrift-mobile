class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final int? itemId;  
  final String message;
  final DateTime createdAt;
  final String? senderName;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.itemId, 
    required this.message,
    required this.createdAt,
    this.senderName,
    required this.isRead,
  });

  Map<String, dynamic> toJson() => {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'item_id': itemId,   
        'message': message,
        'is_read': isRead ? 1 : 0, 
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      itemId: json['item_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender']?['name'],
       isRead: json['is_read'] == 1 || json['is_read'] == true, // parse isRead (bool or int)
    );
  }
}
