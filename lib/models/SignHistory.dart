class SignHistoryModel {
  final String courseCode;
  final String timeSigned;
  final String status;

  SignHistoryModel({
    required this.courseCode,
    required this.timeSigned,
    required this.status,
  });

  factory SignHistoryModel.fromJson(Map<String, dynamic> json) {
    return SignHistoryModel(
      courseCode: json['course_code'],
      timeSigned: json['time_signed'],
      status: json['status'],
    );
  }
}
