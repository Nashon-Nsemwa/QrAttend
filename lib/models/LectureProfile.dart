class LecturerModel {
  String name;
  String email;
  String lecturerId;
  String department;
  List<String> courses;
  List<String> modules;
  String? profileImagePath;

  LecturerModel({
    required this.name,
    required this.email,
    required this.lecturerId,
    required this.department,
    required this.courses,
    required this.modules,
    this.profileImagePath,
  });
}
