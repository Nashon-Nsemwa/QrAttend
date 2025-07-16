class Module {
  final String id;
  final String courseId;
  final String name;
  final String lecturer; // Now maps directly to your Firestore field

  Module({
    required this.id,
    required this.courseId,
    required this.name,
    required this.lecturer,
  });

  factory Module.fromFirestore(
    String id,
    Map<String, dynamic> data,
    String courseId,
  ) {
    return Module(
      id: id,
      courseId: courseId,
      name: data['name'] ?? '',
      lecturer: data['lecturer'] ?? 'Unknown', // ← pull from `lecturer`
    );
  }
}

class AttendanceDetail {
  final String date;
  final String status; // "Present" or "Absent"

  AttendanceDetail({required this.date, required this.status});
}
