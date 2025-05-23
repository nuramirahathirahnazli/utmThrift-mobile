// Bila user tekan poster dekat homescreen, dia akan pergi ke event details page
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:utmthrift_mobile/models/event_model.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event, required String imagePath});

  String formatEventDate(String eventDate) {
    final date = DateTime.parse(eventDate);
    final dayFormat = DateFormat('EEEE, dd MMMM yyyy'); 
    return dayFormat.format(date);
  }

  String formatEventTime(String startTime, String endTime, String eventDate) {
    final startDateTime = DateTime.parse('$eventDate $startTime');
    final endDateTime = DateTime.parse('$eventDate $endTime');
    final timeFormat = DateFormat('hh.mm a'); 

    final start = timeFormat.format(startDateTime);
    final end = timeFormat.format(endDateTime);

    return '$start - $end';
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              event.fullPosterUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 100);
              },
            ),
            const SizedBox(height: 16),
            Text(
              event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 6),
                Text(
                  formatEventDate(event.eventDate),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 6),
                Text(
                  formatEventTime(event.startTime, event.endTime, event.eventDate),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    event.location,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Event Description",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
