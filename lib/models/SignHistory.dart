class SignHistoryModel {
  final String moduleCode;
  final String timeSigned;
  final String status;

  SignHistoryModel({
    required this.moduleCode,
    required this.timeSigned,
    required this.status,
  });

  factory SignHistoryModel.fromMap(Map<String, dynamic> data) {
    return SignHistoryModel(
      moduleCode: data['course_code'] ?? '',
      timeSigned: data['time_signed'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
