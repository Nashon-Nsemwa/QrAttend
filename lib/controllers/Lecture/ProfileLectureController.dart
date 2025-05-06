import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrattend/models/LectureProfile.dart';

class ProfileLectureController extends GetxController {
  var isEditing = false.obs;
  var showDeleteConfirm = false.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    nameController.text = lecturer.value.name;
    emailController.text = lecturer.value.email;
  }

  // Mocked lecturer data
  final lecturer =
      LecturerModel(
        name: 'Dr. Jane Smith',
        email: 'jane.smith@university.com',
        lecturerId: 'L987654321',
        department: 'Computer Science Department',
        courses: ['Computer Science', 'Information Technology'],
        modules: ['Data Structures', 'Algorithms', 'Database Systems'],
        profileImagePath: null,
      ).obs;

  final picker = ImagePicker();

  void toggleEdit() => isEditing.value = !isEditing.value;

  void updateName(String name) => lecturer.update((l) => l?.name = name);

  void updateEmail(String email) => lecturer.update((l) => l?.email = email);

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      lecturer.update((l) => l?.profileImagePath = picked.path);
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
