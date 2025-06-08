// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/chatmessage_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  final int sellerId;
  final int? itemId;
  final String? itemName;
  final String sellerName;
  final int currentUserId;
  final bool isSeller;
  final String? initialMessage;

  const ChatScreen({
    super.key,
    required this.sellerId,
    this.itemId,
    this.itemName,
    required this.sellerName,
    required this.currentUserId,
    this.isSeller = false,
    this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  late ChatMessageViewModel _viewModel;
  late TextEditingController _messageController;

  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.initialMessage ?? '');

    _messageController.addListener(() {
      final canSendNow = _messageController.text.trim().isNotEmpty;
      if (canSendNow != _canSend) {
        setState(() {
          _canSend = canSendNow;
        });
      }
    });

    _viewModel = ChatMessageViewModel();

    _viewModel.initialize(
      currentUserId: widget.currentUserId,
      sellerId: widget.sellerId,
      itemId: widget.itemId ?? 0,
    );

    _viewModel.loadMessages().then((_) {
      _viewModel.markMessagesAsRead(
        chatPartnerId: widget.sellerId,
        userType: widget.isSeller ? 'seller' : 'buyer',
        itemId: widget.itemId ?? 0,
      );
      _scrollToBottom();
    });
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    try {
      await _viewModel.sendMessage(trimmedText);
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Failed to send message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message. Please try again.')),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  BorderRadius _messageBorderRadius(bool isMe) {
    return BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
      bottomRight: isMe ? Radius.zero : const Radius.circular(12),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true); // Return 'true' to trigger refresh
            },
          ),
          title: Text("Chat with ${widget.sellerName}"),
        ),
        body: Consumer<ChatMessageViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Assume vm.messages is sorted oldest -> newest
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
                            color: isMe
                                ? Theme.of(context).primaryColor.withOpacity(0.8)
                                : Colors.grey[200],
                            borderRadius: _messageBorderRadius(isMe),
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
                          controller: _messageController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: _canSend ? sendMessage : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color: _canSend ? Theme.of(context).primaryColor : Colors.grey,
                        onPressed: _canSend
                            ? () {
                                sendMessage(_messageController.text);
                              }
                            : null,
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
