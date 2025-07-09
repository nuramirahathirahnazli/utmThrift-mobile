import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utmthrift_mobile/models/event_model.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

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

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 100,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: Text(
          event.title,
          style: const TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.color2,
        iconTheme: const IconThemeData(color: AppColors.base),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clickable Event Poster
            GestureDetector(
              onTap: () => _showFullScreenImage(context, event.fullPosterUrl),
              child: Hero(
                tag: 'event-poster-${event.id}',
                child: Container(
                  height: 300, // Increased height for better visibility
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.color12,
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        event.fullPosterUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: AppColors.color3,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color10,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Event Details Card
                  Card(
                    color: AppColors.color12,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: "Date",
                            value: formatEventDate(event.eventDate),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.access_time_outlined,
                            label: "Time",
                            value: formatEventTime(event.startTime, event.endTime, event.eventDate),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.location_on_outlined,
                            label: "Location",
                            value: event.location,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Event Description
                  const Text(
                    "About This Event",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.color12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.color10.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.color2,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.color10.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.color10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}