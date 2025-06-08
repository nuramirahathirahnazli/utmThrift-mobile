// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class EventService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Fetch latest events (with optional limit), requires auth token
  static Future<List<Event>> fetchEvents({int limit = 4}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Token: $token");
    
    final response = await http.get(
      Uri.parse('$baseUrl/events?limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events: ${response.statusCode} ${response.body}');
    }
  }

  // Fetch event details by ID, requires auth token
  static Future<Event> fetchEventDetails(int id, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");
    
    final response = await http.get(
      Uri.parse('$baseUrl/events/$id'),
     headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Event.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load event details: ${response.statusCode} ${response.body}');
    }
  }
}
