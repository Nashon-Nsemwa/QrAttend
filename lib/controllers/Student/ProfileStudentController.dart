import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrattend/models/StudentProfile.dart' show StudentModel;

class ProfileStudentController extends GetxController {
  var isEditing = false.obs;
  final picker = ImagePicker();
  var showDeleteConfirm = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    nameController.text = student.value.name;
    emailController.text = student.value.email;
  }

  var student =
      StudentModel(
        name: 'John Doe',
        email: 'john.doe@student.university.com',
        registrationNo: '123456789',
        course: 'Computer Science',
        year: 'Year 2',
        profileImagePath: null,
      ).obs;

  void toggleEdit() => isEditing.value = !isEditing.value;

  void updateName(String name) => student.update((s) => s?.name = name);
  void updateEmail(String email) => student.update((s) => s?.email = email);

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      student.update((s) => s?.profileImagePath = picked.path);
    }
  }

  void handleDeleteAccount() {
    // Simulate delete
    showDeleteConfirm.value = false;
    Get.snackbar(
      "Account Deleted",
      "Your lecturer account has been deleted.",
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
