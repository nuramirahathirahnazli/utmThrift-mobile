// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:flutter/material.dart';
import '../models/chatmessage_model.dart';
import '../services/chat_service.dart';

class ChatMessageViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? currentUserId;
  int? sellerId;
  int? itemId;
  String? paymentMethod;

  DateTime? _lastAutoReplyTime;

  // To hold unread messages count from API
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  int get unreadMessageCount => _messages.where((msg) => !msg.isRead).length;

  ChatMessageViewModel();

  void initialize({
    int? currentUserId,
    int? sellerId,
    int? itemId,
    String? paymentMethod,
  }) {
    this.currentUserId = currentUserId;
    this.sellerId = sellerId;
    this.itemId = itemId;
    this.paymentMethod = paymentMethod;
    print('Initialized ViewModel with currentUserId=$currentUserId, sellerId=$sellerId, itemId=$itemId, paymentMethod=$paymentMethod');
  }

  
  Future<void> loadMessages() async {
    if (currentUserId == null || sellerId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _chatService.fetchMessages(
        currentUserId: currentUserId!,
        sellerId: sellerId!,
        itemId: itemId!,
      );
      print('Loaded ${_messages.length} messages');
    } catch (e) {
      print('Message load error: $e');
      _messages = [];
    }

    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> fetchUnreadMessagesForBuyer() async {
    if (currentUserId == null) {
      print('Error: currentUserId is null');
      return;
    }

    print('Fetching unread messages for buyer with currentUserId=$currentUserId...');
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _chatService.fetchMessagesForBuyer(currentUserId!);
      print('Fetched ${_messages.length} messages for buyer');
      print('Unread message count after fetch: $unreadMessageCount');
    } catch (e) {
      _messages = [];
      print('Error fetching unread messages for buyer: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUnreadMessagesForSeller() async {
    if (currentUserId == null) {
      print('Error: currentUserId is null');
      return;
    }

    print('Fetching unread messages for seller with currentUserId=$currentUserId...');
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _chatService.fetchMessagesForSeller(currentUserId!);
      print('Fetched ${_messages.length} messages for seller');
      print('Unread message count after fetch: $unreadMessageCount');
    } catch (e) {
      _messages = [];
      print('Error fetching unread messages for seller: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      print('Ignoring empty message');
      return;
    }

    if (currentUserId == null || sellerId == null) {
      print('Error: Missing required IDs');
      return;
    }

    print('Sending: "$message"');
    try {
      final newMsg = await _chatService.sendMessage(
        loggedInUserId: currentUserId!,
        chatPartnerId: sellerId!,
        itemId: itemId,
        message: message,
      );
      
      _messages.add(newMsg);
      notifyListeners();
      _triggerAutoReply(message);
    } catch (e) {
      print('Message send error: $e');
      rethrow;
    }
  }

  void _triggerAutoReply(String userMessage) {
    const autoReplyText = "Hello! Thanks for your message. Let's arrange the meeting. State your preferred meeting place and date.";
    final meetKeywords = ['meet', 'payment', 'arrange', 'handover', 'deliver'];
    
    final shouldReply = 
        // Check payment method
        (paymentMethod?.toLowerCase().contains("meet") ?? false) ||
        // Or message contains keywords
        meetKeywords.any((word) => userMessage.toLowerCase().contains(word));
    
    final canReply = 
        !hasAutoReplyBeenSent(autoReplyText) &&
        (_lastAutoReplyTime == null || 
         DateTime.now().difference(_lastAutoReplyTime!) > const Duration(minutes: 5));

    if (shouldReply && canReply) {
      print('Triggering auto-reply...');
      _lastAutoReplyTime = DateTime.now();
      sendAutoReplyFromSeller(autoReplyText);
    }
  }
  
  bool isInquiryMessage(String msg) {
  final inquiryKeywords = ['price', 'available', 'condition', 'details'];
  return inquiryKeywords.any((word) => msg.toLowerCase().contains(word));
}

  Future<void> markMessagesAsRead({
    required int chatPartnerId,
    required String userType,
    int? itemId,
  }) async {
    await _chatService.markMessagesAsRead(
      chatPartnerId: chatPartnerId,
      userType: userType,
      itemId: itemId,
    );

    // Update local messages
    for (var msg in _messages.where((m) => !m.isRead && m.senderId == chatPartnerId)) {
      msg.isRead = true;
    }
    
    await fetchUnreadMessageCount();
    notifyListeners();
  }
  
  Future<void> fetchUnreadMessageCount() async {
    try {
      _unreadCount = await _chatService.fetchUnreadMessageCount();
      print("Unread count fetched from API: $_unreadCount");
      notifyListeners();
    } catch (e) {
      print("Failed to fetch unread count: $e");
    }
  }

  Future<void> sendAutoReplyFromSeller(String message) async {
    if (sellerId == null || currentUserId == null) return;
    
    try {
      final reply = await _chatService.sendMessage(
        loggedInUserId: sellerId!,
        chatPartnerId: currentUserId!,
        itemId: itemId,
        message: message,
      );
      
      _messages.add(reply);
      notifyListeners();
    } catch (e) {
      print('Auto-reply failed: $e');
    }
  }

  bool hasAutoReplyBeenSent(String autoReplyText) {
    return messages.any((msg) =>
      msg.senderId == sellerId && // From seller
      msg.message.toLowerCase().contains("thanks for your message") // Partial match
    );
  }

  // track if meeting place has been confirmed
   bool hasMeetingPlaceBeenStated() {
    return _messages.any((msg) =>
      msg.senderId == currentUserId &&
      msg.message.toLowerCase().contains("meet at"));
  }

  bool hasConfirmedMeetPlace = false;

  Future<void> confirmMeetingPlace() async {
    await sendMessage("Meeting place confirmed. Looking forward to meet!");
    hasConfirmedMeetPlace = true;
    notifyListeners();
  }
  
  bool isItemMarkedSold = false;

  Future<void> markItemAsSold(int itemId) async {
    try {
      await _chatService.markItemAsSold(itemId);
      isItemMarkedSold = true;
      notifyListeners();
    } catch (e) {
      print("Mark as sold error: $e");
    }
  }


}
