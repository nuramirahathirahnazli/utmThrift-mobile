// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/models/chatpartner_model.dart';
import '../models/chatmessage_model.dart';

class ChatService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _buildHeaders(String? token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }
  
  // Get chat messages between current user and seller (or by item)
  Future<List<ChatMessage>> fetchMessages({
    required int currentUserId,
    required int sellerId,
    required int itemId,
  }) async {
    final token = await _getToken();
    if (token == null) {
      print('No auth token found');
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/messages?with_user_id=$sellerId&item_id=$itemId'),
      headers: _buildHeaders(token),
    );

    print('fetchMessages status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Number of messages fetched: ${data.length}');
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      print('Failed to fetch messages. Body: ${response.body}');
      throw Exception('Failed to fetch messages');
    }
  }

  // Send a message
  Future<ChatMessage> sendMessage({
    required int currentUserId,
    required int sellerId,
    required int itemId,
    required String message,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: _buildHeaders(token),
      body: jsonEncode({
            'receiver_id': sellerId,
            'item_id': itemId,
            'message': message,
      }),
    );

    final data = jsonDecode(response.body);
    print('Cart API response data: $data');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  // Fetch messages for a specific seller
  Future<List<ChatMessage>> fetchMessagesForSeller(int sellerId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/seller/messages/$sellerId'),
      headers: _buildHeaders(token),
    );

    print('fetchMessagesForSeller status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Number of messages for seller $sellerId: ${data.length}');
      return data.map((item) => ChatMessage.fromJson(item)).toList();
    } else {
      print('Failed to load messages for seller $sellerId. Body: ${response.body}');
      throw Exception('Failed to load messages');
    }
  }

  Future<int> fetchUnreadMessageCount(String token) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/messages/unread-count'),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['unreadCount'] as int;
    } else {
      throw Exception('Failed to fetch unread count');
    }
  }
  
  Future<List<ChatPartner>> fetchChatList() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/messages/chat-list'),
      headers: _buildHeaders(token),
    );

    print('Chat list response: ${response.body}');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatPartner.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch chat list');
    }
  }

  Future<void> markMessagesAsRead({
    required int chatPartnerId, // the *other* user's ID in the chat
    required String userType,   // 'buyer' or 'seller'
    int? itemId,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$baseUrl/messages/mark-as-read');

    final body = jsonEncode({
      'userId': chatPartnerId, // pass partner's ID here
      'userType': userType,
      'itemId': itemId,
    });

    final response = await http.post(
      url,
      headers: _buildHeaders(token),
      body: body,
    );

    if (response.statusCode == 200) {
      print('Messages marked as read successfully.');
    } else {
      print('Failed to mark messages as read: ${response.body}');
      throw Exception('Failed to mark messages as read');
    }
  }



}
