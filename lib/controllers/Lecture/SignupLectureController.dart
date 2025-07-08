import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/SignupLectureModel.dart';

class SignupLectureController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final name = TextEditingController();
  final email = TextEditingController();
  final lectureId = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // Dropdown
  var selectedDepartment = ''.obs;
  var departments = <String>[].obs;

  // Password visibility
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
  }

  /// 🔄 Fetch departments from Firestore
  void fetchDepartments() {
    _firestore.collection('departments').snapshots().listen((snapshot) {
      departments.value =
          snapshot.docs
              .map((doc) => doc.data()['name'])
              .where(
                (name) => name != null && name is String && name.isNotEmpty,
              )
              .cast<String>()
              .toList();
    });
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  /// ✅ Submit and save lecture to Firestore
  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      // Check if lecture already exists
      final existing =
          await _firestore
              .collection('lectures')
              .where('lectureId', isEqualTo: lectureId.text.trim())
              .get();

      if (existing.docs.isNotEmpty) {
        Get.snackbar("Error", "Lecture ID already exists");
        return;
      }

      final lecture = LectureModel(
        name: name.text.trim(),
        email: email.text.trim(),
        lectureId: lectureId.text.trim(),
        department: selectedDepartment.value,
        password: password.text.trim(),
      );

      // Let Firestore generate the document ID automatically
      await _firestore.collection('lectures').add(lecture.toMap());

      Get.snackbar("Success", "Signed up as ${lecture.name}");

      Future.delayed(const Duration(seconds: 1), () {
        Get.offNamed('/Signin_Student'); // Replace if needed
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to sign up: $e");
      print("$e");
    }
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    lectureId.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
