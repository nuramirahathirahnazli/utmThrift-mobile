// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventViewModel extends ChangeNotifier {
  List<Event> latestEvents = [];
  List<Event> allEvents = [];
  bool isLoading = false;

  Future<void> getLatestEvents({int limit = 4}) async {
    isLoading = true;
    notifyListeners();

    try {
      latestEvents = await EventService.fetchEvents(limit: limit);
    } catch (e) {
      print('Error loading events: $e');
      latestEvents = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllEvents() async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch all events by calling fetchEvents without limit or with a large limit
      allEvents = await EventService.fetchEvents(limit: 1000);  // or remove limit param and adjust service accordingly
    } catch (e) {
      print('Error loading all events: $e');
      allEvents = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
