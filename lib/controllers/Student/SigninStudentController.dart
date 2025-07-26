import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrattend/services/NotificationServices.dart';
import '../../utils/showAlert.dart'; // Adjust the import path if needed

class SigninStudentController extends GetxController {
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscureText = true.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _box = GetStorage();

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
    final regNo = regNoController.text.trim();
    final password = passwordController.text.trim();

    if (regNo.isEmpty || password.isEmpty) {
      showAlert("Error", "Please fill in all fields", Colors.red);
      return;
    }

    _showLoading();

    try {
      final query =
          await _firestore
              .collection('students')
              .where('registrationNumber', isEqualTo: regNo)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        _hideLoading();
        showAlert(
          "Error",
          "No student found with that registration number",
          Colors.red,
        );
        return;
      }

      final studentData = query.docs.first.data();
      final email = studentData['email'];

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _box.write('role', 'student');
      await NotificationService.initialize();

      _hideLoading();
      showAlert("Success", "Login successful", Colors.green);

      Future.delayed(const Duration(milliseconds: 600), () {
        Get.offAllNamed('/StudentNavigation');
      });
    } on FirebaseAuthException catch (e) {
      _hideLoading();
      showAlert(
        "Login Failed",
        e.message ?? "Authentication failed",
        Colors.red,
      );
    } catch (e) {
      _hideLoading();
      showAlert("Error", "Unexpected error: $e", Colors.red);
    }
  }

  Future<void> forgotPassword() async {
    final regNo = regNoController.text.trim();

    if (regNo.isEmpty) {
      showAlert(
        "Error",
        "Please enter your registration number first",
        Colors.orange,
      );
      return;
    }

    _showLoading();

    try {
      final query =
          await _firestore
              .collection('students')
              .where('registrationNumber', isEqualTo: regNo)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        _hideLoading();
        showAlert(
          "Error",
          "No student found with that registration number",
          Colors.red,
        );
        return;
      }

      final email = query.docs.first['email'];

      await _auth.sendPasswordResetEmail(email: email);

      _hideLoading();
      showAlert(
        "Password Reset",
        "A reset link has been sent to $email",
        Colors.green,
      );
    } catch (e) {
      _hideLoading();
      showAlert("Error", "Reset failed: $e", Colors.red);
    }
  }

  @override
  void onClose() {
    regNoController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
