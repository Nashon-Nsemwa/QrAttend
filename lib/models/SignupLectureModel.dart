class LectureModel {
  final String name;
  final String email;
  final String lectureId;
  final String department;
  final String password;
  final List<String> courses;
  final List<String> modules;

  LectureModel({
    required this.name,
    required this.email,
    required this.lectureId,
    required this.department,
    required this.password,
    this.courses = const [],
    this.modules = const [],
  });

  factory LectureModel.fromMap(Map<String, dynamic> data) {
    final details = data['details'] ?? {};
    return LectureModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      lectureId: data['lectureId'] ?? '',
      department: data['department'] ?? '',
      password: data['password'] ?? '',
      courses: List<String>.from(details['courses'] ?? []),
      modules: List<String>.from(details['modules'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'lectureId': lectureId,
      'department': department,
      'password': password,
      'details': {'courses': courses, 'modules': modules},
    };
  }
}
