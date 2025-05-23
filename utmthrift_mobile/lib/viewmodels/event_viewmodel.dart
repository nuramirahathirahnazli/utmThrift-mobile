// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventViewModel extends ChangeNotifier {
  List<Event> latestEvents = [];
  bool isLoading = false;

  get allEvents => null;

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

  void fetchAllEvents() {}
}
