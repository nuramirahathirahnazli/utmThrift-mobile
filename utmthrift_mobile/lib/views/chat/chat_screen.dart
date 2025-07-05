import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/chatmessage_viewmodel.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

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
    _messageController.addListener(_updateSendButtonState);
    _initializeChat();
  }

  void _updateSendButtonState() {
    final canSendNow = _messageController.text.trim().isNotEmpty;
    if (canSendNow != _canSend) {
      setState(() => _canSend = canSendNow);
    }
  }

  void _initializeChat() {
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
      await _handleInitialMessage();
    });
  }

  Future<void> _handleInitialMessage() async {
    final shouldSendInitialMessage = (widget.initialMessage?.trim().isNotEmpty ?? false);
    final isBuyer = !widget.isSeller;
    final isMeetUp = widget.paymentMethod == "Meet with Seller";

    final lastMessage = _viewModel.messages.isNotEmpty ? _viewModel.messages.last : null;
    final lastMessageFromBuyer = lastMessage?.senderId == widget.currentUserId;

    if (shouldSendInitialMessage && isBuyer && isMeetUp && lastMessageFromBuyer) {
      if (!_viewModel.messages.any((m) => m.message == widget.initialMessage!.trim())) {
        await sendMessage(widget.initialMessage!.trim());
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!_viewModel.hasAutoReplyBeenSent("Please state the place to meet")) {
        await _viewModel.sendAutoReplyFromSeller("Please state the place to meet");
      }
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    try {
      await _viewModel.sendMessage(trimmedText);
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
            backgroundColor: AppColors.color8, // Red error
          ),
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
        backgroundColor: AppColors.base,
        appBar: AppBar(
          backgroundColor: AppColors.color2, // Maroon app bar
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.base),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: Text(
            widget.sellerName,
            style: const TextStyle(
              color: AppColors.base,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: AppColors.base),
              tooltip: 'Go to Home',
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                widget.isSeller ? '/seller_home' : '/home',
                (route) => false,
              ),
            ),
          ],
        ),
        body: Consumer<ChatMessageViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.color2),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/chat_bg.png'), // Add your own subtle pattern
                        fit: BoxFit.cover,
                        opacity: 0.05,
                      ),
                    ),
                    child: ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      itemCount: vm.messages.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final msg = vm.messages[vm.messages.length - 1 - index];
                        final isMe = msg.senderId == widget.currentUserId;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.color2 // Maroon for sender
                                        : AppColors.color12, // Light yellow for receiver
                                    borderRadius: _messageBorderRadius(isMe),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    msg.message,
                                    style: TextStyle(
                                      color: isMe ? AppColors.base : AppColors.color10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Action Buttons
                if (widget.isSeller && _viewModel.hasMeetingPlaceBeenStated() && !_viewModel.hasConfirmedMeetPlace)
                  _buildActionButton(
                    icon: Icons.check_circle,
                    label: "Confirm Meeting Place",
                    onPressed: () async {
                      await _viewModel.confirmMeetingPlace();
                      setState(() {});
                    },
                  ),

                if (_viewModel.hasConfirmedMeetPlace && !_viewModel.isItemMarkedSold)
                  _buildActionButton(
                    icon: Icons.shopping_bag,
                    label: "Mark Item as Sold",
                    onPressed: () async {
                      if (widget.itemId != null) {
                        await _viewModel.markItemAsSold(widget.itemId!);
                        setState(() {});
                      }
                    },
                  ),

                // Message Input
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.base,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.color3.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.color12, // Light yellow
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _messageController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: _canSend ? AppColors.color2 : AppColors.color3,
                                ),
                                onPressed: _canSend
                                    ? () => sendMessage(_messageController.text)
                                    : null,
                              ),
                            ),
                            onSubmitted: _canSend ? sendMessage : null,
                          ),
                        ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(icon, color: AppColors.base),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.color2, // Maroon
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}