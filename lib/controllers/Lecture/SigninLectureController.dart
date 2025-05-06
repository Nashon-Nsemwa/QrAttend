import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SigninLectureController extends GetxController {
  final TextEditingController lectureIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscureText = true.obs;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void login() {
    String id = lectureIdController.text.trim();
    String password = passwordController.text;

    if (id.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // You can replace this with real backend validation
    if (id == "123" && password == "123") {
      Get.offNamed('/LectureNavigation');
    } else {
      Get.snackbar(
        "Login Failed",
        "Invalid credentials",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    lectureIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
