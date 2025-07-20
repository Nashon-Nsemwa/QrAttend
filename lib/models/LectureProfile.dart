class LectureModel {
  final String name;
  final String email;
  final String lectureId;
  final String department;
  final List<String> courses;
  final List<String> modules;
  final String? profileImagePath;

  LectureModel({
    required this.name,
    required this.email,
    required this.lectureId,
    required this.department,
    required this.courses,
    required this.modules,
    this.profileImagePath,
  });

  factory LectureModel.fromMap(Map<String, dynamic> map) {
    final details = map['details'] ?? {};

    return LectureModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      lectureId: map['lectureId'] ?? '',
      department: map['department'] ?? '',
      courses: List<String>.from(details['courses'] ?? []),
      modules: List<String>.from(details['modules'] ?? []),
      profileImagePath: map['profileImagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'lectureId': lectureId,
      'department': department,
      'profileImagePath': profileImagePath,
      'details': {'courses': courses, 'modules': modules},
    };
  }

  LectureModel copyWith({
    String? name,
    String? email,
    String? lectureId,
    String? department,
    List<String>? courses,
    List<String>? modules,
    String? profileImagePath,
  }) {
    return LectureModel(
      name: name ?? this.name,
      email: email ?? this.email,
      lectureId: lectureId ?? this.lectureId,
      department: department ?? this.department,
      courses: courses ?? this.courses,
      modules: modules ?? this.modules,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  String toString() {
    return 'LectureModel(name: $name, email: $email, id: $lectureId, department: $department, courses: $courses, modules: $modules';
  }
}
