class LectureModel {
  final String name;
  final String email;
  final String lectureId;
  final String department;
  final String password;
  final String authCode;

  LectureModel({
    required this.name,
    required this.email,
    required this.lectureId,
    required this.department,
    required this.password,
    required this.authCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'lectureId': lectureId,
      'department': department,
      'password': password,
      'authCode': authCode,
    };
  }
}
