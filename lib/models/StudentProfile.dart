class StudentModel {
  final String name;
  final String email;
  final String registrationNumber;
  final String course;
  final String year;
  final String?
  profileImagePath; // Could be local path or URL from Firebase Storage

  StudentModel({
    required this.name,
    required this.email,
    required this.registrationNumber,
    required this.course,
    required this.year,
    this.profileImagePath,
  });

  /// Factory constructor to create from Firestore data
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      registrationNumber: map['registrationNumber'] ?? '',
      course: map['course'] ?? '',
      year: map['year'] ?? '',
      profileImagePath: map['profileImagePath'], // May be null
    );
  }

  /// Convert model to map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'regNo': registrationNumber,
      'course': course,
      'year': year,
      if (profileImagePath != null) 'profileImagePath': profileImagePath,
    };
  }

  /// For easier update scenarios
  StudentModel copyWith({
    String? name,
    String? email,
    String? registrationNo,
    String? course,
    String? year,
    String? profileImagePath,
  }) {
    return StudentModel(
      name: name ?? this.name,
      email: email ?? this.email,
      registrationNumber: registrationNumber,
      course: course ?? this.course,
      year: year ?? this.year,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  String toString() {
    return 'Student(name: $name, email: $email, regNo: $registrationNumber, course: $course, year: $year, profileImagePath: $profileImagePath)';
  }
}
