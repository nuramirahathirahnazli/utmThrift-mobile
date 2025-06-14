// ignore_for_file: avoid_print

class Event {
  final int id;
  final String title;
  final String description;
  final String eventDate;
  final String startTime;
  final String endTime;
  final String location;
  final String poster;

  static const String baseUrl = 'http://127.0.0.1:8000/';

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.poster,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
  print('Poster raw value: ${json['poster']}');
  
  return Event(
    id: json['id'],
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    eventDate: json['event_date'] ?? '',
    startTime: json['start_time'] ?? '',
    endTime: json['end_time'] ?? '',
    location: json['location'] ?? '',
    poster: json['poster'] ?? '',

  );
}

String get fullPosterUrl {
  if (poster.startsWith('http')) {
    return poster;
  }
  // Ensure no double slashes when joining
  final cleanPoster = poster.startsWith('/') ? poster.substring(1) : poster;
  return '$baseUrl$cleanPoster';
}


  
}
