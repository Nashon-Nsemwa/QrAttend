import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/SignupStudentModel.dart';

import '../../utils/showAlert.dart'; // ✅ Import your reusable alert

class SignupStudentController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final registrationNumber = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  var selectedCourse = ''.obs;
  var selectedYear = ''.obs;

  var courses = <String>[].obs;
  var years = <String>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
    // Reset selectedYear when selectedCourse changes
    ever(selectedCourse, (_) {
      selectedYear.value = ''; // Clear selected year
      fetchYearsForCourse(); // Reload year list
    });
  }

  void fetchCourses() {
    _firestore.collection('courses').snapshots().listen((snapshot) {
      courses.value =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> fetchYearsForCourse() async {
    if (selectedCourse.value.isEmpty) return;

    final query =
        await _firestore
            .collection('courses')
            .where('name', isEqualTo: selectedCourse.value)
            .get();

    if (query.docs.isNotEmpty) {
      final year = query.docs.first['year'];
      years.value = _parseYearRange(year);
    } else {
      years.clear();
    }
  }

  List<String> _parseYearRange(String yearString) {
    final match = RegExp(r'Year (\d+)').firstMatch(yearString);
    if (match != null) {
      final maxYear = int.parse(match.group(1)!);
      return List.generate(maxYear, (i) => 'Year ${i + 1}');
    }
    return [];
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;
  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  void _showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    final regNo = registrationNumber.text.trim();
    final emailText = email.text.trim();

    _showLoading();

    try {
      final existing =
          await _firestore
              .collection('students')
              .where('registrationNumber', isEqualTo: regNo)
              .get();

      final emailExists =
          await _firestore
              .collection('students')
              .where('email', isEqualTo: emailText)
              .get();

      if (existing.docs.isNotEmpty) {
        _hideLoading();
        showAlert("Error", "Registration number already exists", Colors.red);
        return;
      }

      if (emailExists.docs.isNotEmpty) {
        _hideLoading();
        showAlert("Error", "Email already exists", Colors.red);
        return;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailText,
        password: password.text.trim(),
      );

      final student = StudentModel(
        registrationNumber: regNo,
        name: name.text.trim(),
        email: emailText,
        course: selectedCourse.value,
        year: selectedYear.value,
      );

      await _firestore
          .collection('students')
          .doc(userCredential.user!.uid)
          .set(student.toMap());

      final box = GetStorage();
      box.write('role', 'student');

      _hideLoading();
      showAlert("Success", "Signed up as ${student.name}", Colors.green);

      Get.offAllNamed('/StudentNavigation');
    } on FirebaseAuthException catch (e) {
      _hideLoading();
      showAlert("Auth Error", e.message ?? "Something went wrong", Colors.red);
    } catch (e) {
      _hideLoading();
      showAlert("Error", "Signup failed: $e", Colors.red);
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
}
