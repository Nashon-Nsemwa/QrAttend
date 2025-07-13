class StudentModel {
  final String registrationNumber;
  final String course;
  final String year;
  final String name;
  final String email;

  StudentModel({
    required this.registrationNumber,
    required this.course,
    required this.year,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      "registrationNumber": registrationNumber,
      "course": course,
      "year": year,
      "name": name,
      "email": email,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> data) {
    return StudentModel(
      registrationNumber: data['registrationNumber'],
      course: data['course'],
      year: data['year'],
      name: data['name'],
      email: data['email'],
    );
  }
}
