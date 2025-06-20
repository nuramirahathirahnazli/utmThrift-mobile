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
  final int? orderId;
  final String? paymentMethod;

  const ChatScreen({
    super.key,
    required this.sellerId,
    this.itemId,
    this.itemName,
    required this.sellerName,
    required this.currentUserId,
    this.isSeller = false,
    this.initialMessage,
    this.orderId,
    this.paymentMethod,
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
      paymentMethod: widget.paymentMethod,
    );

    _viewModel.loadMessages().then((_) async {
      _viewModel.markMessagesAsRead(
        chatPartnerId: widget.sellerId,
        userType: widget.isSeller ? 'seller' : 'buyer',
        itemId: widget.itemId ?? 0,
      );

      _scrollToBottom();

      final shouldSendInitialMessage = (widget.initialMessage?.trim().isNotEmpty ?? false);
      final isBuyer = !widget.isSeller;
      final isMeetUp = widget.paymentMethod == "Meet with Seller";

      final lastMessage = _viewModel.messages.isNotEmpty ? _viewModel.messages.last : null;
      final lastMessageFromBuyer = lastMessage?.senderId == widget.currentUserId;

      if (shouldSendInitialMessage && isBuyer && isMeetUp && lastMessageFromBuyer) {
        // Send initial message only if it’s not already in the messages
        if (!_viewModel.messages.any((m) => m.message == widget.initialMessage!.trim())) {
          await sendMessage(widget.initialMessage!.trim());
          await Future.delayed(const Duration(seconds: 1));
        }

        if (!_viewModel.hasAutoReplyBeenSent("Please state the place to meet")) {
          await _viewModel.sendAutoReplyFromSeller("Please state the place to meet");
        }
      }
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
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
              Navigator.pop(context, true); // Trigger refresh on return
            },
          ),
          title: Text("Chat with ${widget.sellerName}"),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Go to Home',
              onPressed: () {
                if (widget.isSeller) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/seller_home', (route) => false);
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                }
              },
            ),
          ],
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

                // Confirm Meeting Place Button (Seller)
                if (widget.isSeller &&
                    _viewModel.hasMeetingPlaceBeenStated() &&
                    !_viewModel.hasConfirmedMeetPlace)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Confirm Meeting Place"),
                      onPressed: () async {
                        await _viewModel.confirmMeetingPlace();
                        setState(() {});
                      },
                    ),
                  ),

                // Mark Item as Sold Button (Seller)
                if (_viewModel.hasConfirmedMeetPlace &&
                    !_viewModel.isItemMarkedSold)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text("Mark Item as Sold"),
                      onPressed: () async {
                        await _viewModel.markItemAsSold(widget.itemId!);
                        setState(() {});
                      },
                    ),
                  ),

                // Chat input
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
