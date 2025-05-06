class StudentModel {
  final String registrationNumber;
  final String course;
  final String year;
  final String authCode;
  final String name;
  final String email;
  final String password;

  StudentModel({
    required this.registrationNumber,
    required this.course,
    required this.year,
    required this.authCode,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "registrationNumber": registrationNumber,
      "course": course,
      "year": year,
      "authCode": authCode,
      "name": name,
      "email": email,
      "password": password,
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      registrationNumber: json['registrationNumber'],
      course: json['course'],
      year: json['year'],
      authCode: json['authCode'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }
}
