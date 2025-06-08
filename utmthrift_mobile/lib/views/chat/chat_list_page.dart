// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/chatpartner_model.dart';
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

      final Map<int, ChatPartner> groupedChats = {};

      for (var chat in chats) {
        if (groupedChats.containsKey(chat.sellerId)) {
          final existing = groupedChats[chat.sellerId]!;

          // Keep latest lastMessage by timestamp or just keep the one you want
          // Assuming lastMessage is a string, you could add lastUpdated for better sorting in API
          groupedChats[chat.sellerId] = ChatPartner(
            sellerId: existing.sellerId,
            name: existing.name,
            unreadCount: existing.unreadCount + chat.unreadCount,
            lastMessage: chat.lastMessage ?? existing.lastMessage,
          );
        } else {
          groupedChats[chat.sellerId] = chat;
        }
      }

      setState(() {
        _chatList = groupedChats.values.toList();
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
              : _chatList.isEmpty
                  ? const Center(child: Text("No chats available"))
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
                            subtitle: Text(
                              chatPartner.lastMessage ?? 'Tap to chat',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              print('Tapped chatPartner: sellerId=${chatPartner.sellerId}');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    sellerId: chatPartner.sellerId,
                                    sellerName: chatPartner.name,
                                    currentUserId: widget.currentUserId,
                                    isSeller: isSeller,
                                  ),
                                ),
                              ).then((_) {
                                _loadChatList();
                              });
                                                        },

                          ),
                        );
                      },
                    ),
    );
  }
}
