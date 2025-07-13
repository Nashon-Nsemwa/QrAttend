import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../utils/showAlert.dart'; // Make sure this points to your showAlert file

class SigninLectureController extends GetxController {
  final TextEditingController lectureIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscureText = true.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final box = GetStorage();

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void _showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  Future<void> login() async {
    final lectureId = lectureIdController.text.trim();
    final password = passwordController.text;

    if (lectureId.isEmpty || password.isEmpty) {
      showAlert("Error", "Please fill in all fields", Colors.red);
      return;
    }

    _showLoading();

    try {
      final query =
          await _firestore
              .collection('lectures')
              .where('lectureId', isEqualTo: lectureId)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        _hideLoading();
        showAlert("Login Failed", "Lecture ID not found", Colors.red);
        return;
      }

      final email = query.docs.first['email'];

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      box.write('role', 'lecture');

      _hideLoading();
      showAlert("Success", "Login successful", Colors.green);

      Future.delayed(const Duration(milliseconds: 600), () {
        Get.offNamed('/LectureNavigation');
      });
    } on FirebaseAuthException catch (e) {
      _hideLoading();
      showAlert(
        "Login Failed",
        e.message ?? "Authentication error",
        Colors.red,
      );
    } catch (e) {
      _hideLoading();
      showAlert("Error", "Unexpected error: $e", Colors.red);
    }
  }

  Future<void> resetPassword() async {
    final lectureId = lectureIdController.text.trim();

    if (lectureId.isEmpty) {
      showAlert(
        "Input Required",
        "Enter Lecture ID to reset password",
        Colors.orange,
      );
      return;
    }

    try {
      final query =
          await _firestore
              .collection('lectures')
              .where('lectureId', isEqualTo: lectureId)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        showAlert("Error", "Lecture ID not found", Colors.red);
        return;
      }

      final email = query.docs.first['email'];

      await _auth.sendPasswordResetEmail(email: email);
      showAlert(
        "Password Reset",
        "Check your email to reset password",
        Colors.green,
      );
    } catch (e) {
      showAlert("Error", "Reset failed: $e", Colors.red);
    }
  }

  @override
  void onClose() {
    lectureIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
