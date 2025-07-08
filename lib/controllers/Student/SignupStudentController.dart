import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/SignupStudentModel.dart';

class SignupStudentController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Controllers
  final registrationNumber = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // Dropdown selections
  var selectedCourse = ''.obs;
  var selectedYear = ''.obs;

  // Dynamic lists
  var courses = <String>[].obs;
  var years = <String>[].obs;

  // Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Password visibility
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
    // Listen for course change to fetch years
    ever(selectedCourse, (_) => fetchYearsForCourse());
  }

  /// 🔄 Fetch course names from Firestore
  void fetchCourses() {
    _firestore.collection('courses').snapshots().listen((snapshot) {
      courses.value =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  /// 🔄 Fetch dynamic years based on selected course
  Future<void> fetchYearsForCourse() async {
    if (selectedCourse.value.isEmpty) return;
    final query =
        await _firestore
            .collection('courses')
            .where('name', isEqualTo: selectedCourse.value)
            .get();

    if (query.docs.isNotEmpty) {
      final year = query.docs.first['year']; // Example: "Year 3"
      final yearList = _parseYearRange(year);
      years.value = yearList;
    } else {
      years.clear();
    }
  }

  /// 🧠 Parse "Year 3" → ['Year 1', 'Year 2', 'Year 3']
  List<String> _parseYearRange(String yearString) {
    final match = RegExp(r'Year (\d+)').firstMatch(yearString);
    if (match != null) {
      final maxYear = int.parse(match.group(1)!);
      return List.generate(maxYear, (i) => 'Year ${i + 1}');
    }
    return [];
  }

  /// ✅ Save student to Firebase
  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      // Check for duplicate registration number
      final existing =
          await _firestore
              .collection('students')
              .where(
                'registrationNumber',
                isEqualTo: registrationNumber.text.trim(),
              )
              .get();

      if (existing.docs.isNotEmpty) {
        Get.snackbar("Error", "Registration number already exists");
        return;
      }

      final student = StudentModel(
        registrationNumber: registrationNumber.text.trim(),
        name: name.text.trim(),
        email: email.text.trim(),
        course: selectedCourse.value,
        year: selectedYear.value,
        password: password.text.trim(),
      );

      await _firestore.collection('students').add(student.toMap());

      Get.snackbar("Success", "Signed up as ${student.name}");
      Future.delayed(const Duration(seconds: 1), () {
        Get.offNamed('/Signin_Student');
      });
    } catch (e) {
      Get.snackbar("Error", "Signup failed: $e");
    }
  }

  @override
  void onClose() {
    registrationNumber.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;
}
