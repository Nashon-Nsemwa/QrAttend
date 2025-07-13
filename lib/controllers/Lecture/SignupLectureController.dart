import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/SignupLectureModel.dart';
import '../../utils/showAlert.dart';

class SignupLectureController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final lectureId = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  var selectedDepartment = ''.obs;
  var departments = <String>[].obs;

  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
  }

  void fetchDepartments() {
    _firestore.collection('departments').snapshots().listen((snapshot) {
      departments.value =
          snapshot.docs
              .map((doc) => doc.data()['name'])
              .whereType<String>()
              .toList();
    });
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  void showLoadingDialog() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    final id = lectureId.text.trim();
    final mail = email.text.trim();

    try {
      isLoading.value = true;
      showLoadingDialog(); // Show loading spinner

      // Check if lecture ID already exists
      final idCheck =
          await _firestore
              .collection('lectures')
              .where('lectureId', isEqualTo: id)
              .get();

      if (idCheck.docs.isNotEmpty) {
        Get.back(); // Close loading dialog
        showAlert("Error", "Lecture ID already exists", Colors.red);
        return;
      }

      // Check if email already used
      final emailCheck =
          await _firestore
              .collection('lectures')
              .where('email', isEqualTo: mail)
              .get();

      if (emailCheck.docs.isNotEmpty) {
        Get.back(); // Close loading dialog
        showAlert(
          "Error",
          "Email already used for another lecture",
          Colors.red,
        );
        return;
      }

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: mail,
        password: password.text.trim(),
      );

      // Create Firestore document
      final lecture = LectureModel(
        name: name.text.trim(),
        email: mail,
        lectureId: id,
        department: selectedDepartment.value,
      );

      await _firestore
          .collection('lectures')
          .doc(userCredential.user!.uid)
          .set(lecture.toMap());

      // Save role locally
      box.write('role', 'lecture');

      Get.back(); // Close loading dialog

      showAlert("Success", "Signed up as ${lecture.name}", Colors.green);

      Future.delayed(const Duration(seconds: 1), () {
        Get.offNamed('/LectureNavigation');
      });
    } on FirebaseAuthException catch (e) {
      Get.back(); // Close loading dialog
      showAlert("Error", e.message ?? "Authentication failed", Colors.red);
    } catch (e) {
      Get.back(); // Close loading dialog
      showAlert("Error", "Unexpected error: $e", Colors.red);
    } finally {
      isLoading.value = false;
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
