// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/chatpartner_model.dart'; // your new model
import 'package:utmthrift_mobile/services/chat_service.dart';
import 'package:utmthrift_mobile/views/chat/chat_screen.dart';

class ChatListPage extends StatefulWidget {
  final int? sellerId;
  final int? buyerId;
  final int currentUserId;

  const ChatListPage({
    super.key, 
    this.sellerId, 
    this.buyerId,
    required this.currentUserId,
  });

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatService _chatService;
  List<ChatPartner> _chatList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _loadChatList();
  }

  Future<void> _loadChatList() async {
    try {
      final chats = await _chatService.fetchChatList();
      setState(() {
        _chatList = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSeller = widget.sellerId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSeller ? "Seller Chat List" : "Buyer Chat List"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _chatList.length,
                  itemBuilder: (context, index) {
                    final chatPartner = _chatList[index];

                    return Container(
  color: chatPartner.unreadCount > 0 ? Colors.grey[300] : Colors.transparent,
  child: ListTile(
    leading: const CircleAvatar(
      backgroundColor: Colors.orange,
      child: Icon(Icons.person, color: Colors.white),
    ),
    title: Text(
      chatPartner.name,
      style: TextStyle(
        fontWeight: chatPartner.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        color: chatPartner.unreadCount > 0 ? Colors.black : Colors.grey[600],
      ),
    ),
    trailing: chatPartner.unreadCount > 0
        ? Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${chatPartner.unreadCount}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )
        : null,
    subtitle: const Text('Tap to chat'),
    onTap: () {
                        print('Tapped chatPartner: sellerId=${chatPartner.sellerId}, itemId=${chatPartner.itemId}');
                        if (chatPartner.sellerId != null && chatPartner.itemId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                sellerId: chatPartner.sellerId!,
                                itemId: chatPartner.itemId!,
                                itemName: chatPartner.itemName,
                                sellerName: chatPartner.name,
                                currentUserId: widget.currentUserId,
                                isSeller: isSeller,
                              ),
                            ),
                          ).then((_) {
                            // Reload chat list to update unread counts when returning
                            _loadChatList();
                          });

                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid chat partner data')),
                          );
                        }
                      },
  ),
);
                  },
                ),
    );
  }
}
