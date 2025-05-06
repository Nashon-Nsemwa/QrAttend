import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/models/SignupStudentModel.dart';

class SignupStudentController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final registrationNumber = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final authCode = TextEditingController();

  // Dropdown selections
  var selectedCourse = ''.obs;
  var selectedYear = ''.obs;

  // Dynamic lists (simulate database fetched)
  var courses = <String>[].obs;
  var years = <String>[].obs;

  // Password visibility
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoursesAndYears();
  }

  void fetchCoursesAndYears() {
    // Fetched from backend (replace with real logic)
    courses.value = [
      'Computer Science',
      'Software Engineering',
      'Cyber Security',
    ];
    years.value = ['Year I', 'Year II', 'Year III', 'Year IV', 'Year V'];
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;
  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  void submitForm() {
    if (formKey.currentState!.validate()) {
      final student = StudentModel(
        registrationNumber: registrationNumber.text.trim(),
        course: selectedCourse.value,
        year: selectedYear.value,
        authCode: authCode.text.trim(),
        name: name.text.trim(),
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // TODO: Send student data to backend (Firestore, PHP, etc.)
      Get.snackbar("Success", "Signed up as ${student.name}");
      // Navigate to the Sign In page
      Future.delayed(const Duration(seconds: 1), () {
        Get.offNamed(
          '/Signin_Student',
        ); // Replace '/signin' with your actual route
      });
    }
  }

  @override
  void onClose() {
    registrationNumber.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    authCode.dispose();
    super.onClose();
  }
}
