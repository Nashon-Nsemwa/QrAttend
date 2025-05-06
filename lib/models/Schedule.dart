class ScheduleItem {
  final String type;
  final String subject;
  final String time;
  final String venue;
  final String lecturer;

  ScheduleItem({
    required this.type,
    required this.subject,
    required this.time,
    required this.venue,
    required this.lecturer,
  });

  factory ScheduleItem.fromJson(Map<String, String> json) {
    return ScheduleItem(
      type: json['type'] ?? 'lecture',
      subject: json['subject'] ?? '',
      time: json['time'] ?? '',
      venue: json['venue'] ?? '',
      lecturer: json['lecturer'] ?? '',
    );
  }
}
