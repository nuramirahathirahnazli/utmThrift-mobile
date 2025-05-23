// Bila user tekan poster dekat homescreen, dia akan pergi ke event details page
import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/event_model.dart';

class EventDetailsPage extends StatelessWidget {
  final String imagePath;

  const EventDetailsPage({super.key, required this.imagePath, required Event event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Details")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 300),
            const SizedBox(height: 20),
            const Text(
              "Event Details Coming Soon!",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
