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

  // To hold unread messages count from API
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  int get unreadMessageCount => _messages.where((msg) => !msg.isRead).length;

  ChatMessageViewModel();

  void initialize({
    int? currentUserId,
    int? sellerId,
    int? itemId,
  }) {
    this.currentUserId = currentUserId;
    this.sellerId = sellerId;
    this.itemId = itemId;
    print('Initialized ViewModel with currentUserId=$currentUserId, sellerId=$sellerId, itemId=$itemId');
  }

  Future<void> loadMessages() async {
    if (currentUserId == null || sellerId == null || itemId == null) {
      print('Error: currentUserId, sellerId, or itemId is null');
      return;
    }

    print('Loading messages between user $currentUserId and seller $sellerId for item $itemId...');
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
      _messages = [];
      print('Error loading messages: $e');
    }

    _isLoading = false;
    notifyListeners();
  }


// NOTE: Currently used in seller home page to show unread chat previews.
// Consider refactoring later to unify fetch logic.
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
      print('sendMessage called with empty message, ignoring');
      return;
    }

    if (currentUserId == null || sellerId == null || itemId == null) {
      print('Error: currentUserId, sellerId, or itemId is null');
      return;
    }

    print('Sending message: "$message"');
    try {
      final newMsg = await _chatService.sendMessage(
        currentUserId: currentUserId!,
        sellerId: sellerId!,
        itemId: itemId!,
        message: message,
      );
      _messages.add(newMsg);
      print('Message sent and added to list. Total messages: ${_messages.length}');
      print('Unread message count after send: $unreadMessageCount');
      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead({
    required int chatPartnerId,  // other user's ID, NOT the current user
    required String userType,    // 'buyer' or 'seller'
    int? itemId,
  }) async {
    await _chatService.markMessagesAsRead(
      chatPartnerId: chatPartnerId,
      userType: userType,
      itemId: itemId,
    );

    // Update local message list to mark them as read
    for (var msg in _messages) {
      if (!msg.isRead) {
        msg.isRead = true;
      }
    }

    notifyListeners();
  }

  Future<void> fetchUnreadMessageCount() async {
    try {
      _unreadCount = await _chatService.fetchUnreadMessageCount("token");
      print("Unread count fetched from API: $_unreadCount");
      notifyListeners();
    } catch (e) {
      print("Failed to fetch unread count: $e");
    }
  }


}
