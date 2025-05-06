import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SigninStudentController extends GetxController {
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscureText = true.obs;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void login() {
    final regNo = regNoController.text.trim();
    final password = passwordController.text;

    if (regNo.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Replace with actual authentication logic
    if (regNo == "123" && password == "123") {
      Get.offNamed('/StudentNavigation');
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
    regNoController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
