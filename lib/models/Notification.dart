class NotificationModel {
  final String from;
  final String title;
  final String content;
  final String time;
  final DateTime timestamp; // Add this field

  NotificationModel({
    required this.from,
    required this.title,
    required this.content,
    required this.time,
    required this.timestamp,
  });
}
