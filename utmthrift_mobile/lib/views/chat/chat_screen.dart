// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/models/chatmessage_model.dart';
import 'package:utmthrift_mobile/services/chat_service.dart';
import 'package:utmthrift_mobile/viewmodels/chatmessage_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  final int sellerId;
  final int itemId;
  final String itemName;
  final String sellerName;
  final int currentUserId;
  final bool isSeller;


  const ChatScreen({
    super.key,
    required this.sellerId,
    required this.itemId,
    required this.itemName,
    required this.sellerName,
    required this.currentUserId,
    this.isSeller = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService chatService = ChatService();

  List<ChatMessage> messages = [];
  bool isLoading = false;

  late ChatMessageViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = ChatMessageViewModel();
    
    _viewModel.initialize(
      currentUserId: widget.currentUserId,
      sellerId: widget.sellerId,
      itemId: widget.itemId,
    );

    // Load messages
    if (widget.itemId > 0) {
      _viewModel.loadMessages().then((_) {
        // Mark messages as read after loaded
        _viewModel.markMessagesAsRead(
          chatPartnerId: widget.sellerId,   // seller is chat partner here
          userType: widget.isSeller ? 'seller' : 'buyer',
          itemId: widget.itemId,
        );
      });
    } else {
      _viewModel.fetchUnreadMessagesForSeller();
    }
  }


  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final messageText = text.trim();
    _controller.clear();

    try {
      final sentMessage = await chatService.sendMessage(
        currentUserId: widget.currentUserId,
        sellerId: widget.sellerId,
        itemId: widget.itemId,
        message: messageText,
      );

      setState(() {
        messages.add(sentMessage);
      });

      _scrollToBottom();
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

@override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
Widget build(BuildContext context) {
  return ChangeNotifierProvider.value(
    value: _viewModel,
    child: Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.sellerName}"),
      ),
      body: Consumer<ChatMessageViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: vm.messages.length,
                  itemBuilder: (context, index) {
                    final msg = vm.messages[vm.messages.length - 1 - index];
                    final isMe = msg.senderId == widget.currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                          ),
                        ),
                        child: Text(msg.message),
                      ),
                    );

                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        vm.sendMessage(_controller.text);
                        _controller.clear();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
  
}
