class StudentModel {
  String name;
  String email;
  String registrationNo;
  String course;
  String year;
  String? profileImagePath;

  StudentModel({
    required this.name,
    required this.email,
    required this.registrationNo,
    required this.course,
    required this.year,
    this.profileImagePath,
  });
}
