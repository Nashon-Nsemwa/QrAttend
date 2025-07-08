class StudentModel {
  final String registrationNumber;
  final String course;
  final String year;
  final String name;
  final String email;
  final String password;

  StudentModel({
    required this.registrationNumber,
    required this.course,
    required this.year,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      "registrationNumber": registrationNumber,
      "course": course,
      "year": year,
      "name": name,
      "email": email,
      "password": password,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> data) {
    return StudentModel(
      registrationNumber: data['registrationNumber'],
      course: data['course'],
      year: data['year'],
      name: data['name'],
      email: data['email'],
      password: data['password'],
    );
  }
}
