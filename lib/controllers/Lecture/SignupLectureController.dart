import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/models/SignupLectureModel.dart';

class SignupLectureController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final name = TextEditingController();
  final email = TextEditingController();
  final lectureId = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final authCode = TextEditingController();

  // Dropdown selections
  var selectedDepartment = ''.obs;

  // Departments list (simulate backend fetch)
  var departments = <String>[].obs;

  // Password visibility
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
  }

  void fetchDepartments() {
    // Replace this with actual backend call
    departments.value = [
      'Computing Science',
      'Health Department',
      'Education Department',
      'Business Department',
    ];
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  void submitForm() {
    if (formKey.currentState!.validate()) {
      final lecture = LectureModel(
        name: name.text.trim(),
        email: email.text.trim(),
        lectureId: lectureId.text.trim(),
        department: selectedDepartment.value,
        password: password.text.trim(),
        authCode: authCode.text.trim(),
      );

      // TODO: Submit lecture to backend (Firestore, PHP, etc.)
      Get.snackbar("Success", "Signed up as ${lecture.name}");
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
    name.dispose();
    email.dispose();
    lectureId.dispose();
    password.dispose();
    confirmPassword.dispose();
    authCode.dispose();
    super.onClose();
  }
}
