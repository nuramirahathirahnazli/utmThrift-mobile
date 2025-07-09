// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/chatpartner_model.dart';
import 'package:utmthrift_mobile/services/chat_service.dart';
import 'package:utmthrift_mobile/views/chat/chat_screen.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

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
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          "My Chats",
          style: TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: AppColors.color2, // Maroon app bar
        iconTheme: const IconThemeData(color: AppColors.base),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.color2),
            )
          : _error != null
              ? const Center(
                  child: Text(
                    'Error loading chats',
                    style: TextStyle(
                      color: AppColors.color8, // Red error text
                      fontSize: 16,
                    ),
                  ),
                )
              : _chatList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_outlined,
                            size: 64,
                            color: AppColors.color3, // Light pink icon
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No chats yet",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.color10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Start a conversation and your chats will appear here",
                            style: TextStyle(
                              color: AppColors.color10.withOpacity(0.6),
                            ),
                          ),

                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadChatList,
                      color: AppColors.color2,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _chatList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chatPartner = _chatList[index];
                          final hasUnread = chatPartner.unreadCount > 0;

                          return Card(
                            color: hasUnread 
                                ? AppColors.color11.withOpacity(0.3) // Light pink for unread
                                : AppColors.color12, // Light yellow for read
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
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
                                ).then((_) => _loadChatList());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.color2, // Maroon
                                      child: Text(
                                        chatPartner.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  chatPartner.name,
                                                  style: TextStyle(
                                                    fontWeight: hasUnread 
                                                        ? FontWeight.bold 
                                                        : FontWeight.normal,
                                                    color: AppColors.color10,
                                                    fontSize: 16,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (hasUnread)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.color4, // Red
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${chatPartner.unreadCount}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            chatPartner.lastMessage ?? 'Tap to start chatting',
                                            style: TextStyle(
                                              color: hasUnread
                                                  ? AppColors.color10
                                                  : AppColors.color10.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}