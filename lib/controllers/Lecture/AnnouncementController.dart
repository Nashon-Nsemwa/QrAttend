import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:qrattend/models/annoncementmodel.dart';

class AnnouncementController extends GetxController {
  var selectedCourse = RxnString();
  var title = ''.obs;
  var content = ''.obs;
  var isSending = false.obs;
  var announcements = <Announcement>[].obs;
  var courses = <String>[].obs; // Courses list will be fetched from API
  var isLoadingCourses = false.obs;

  // Controller for TextFields
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchModules(); // Fetch modules when controller is initialized
  }

  // Simulate fetching modules from API
  void fetchModules() async {
    try {
      isLoadingCourses.value = true;

      await Future.delayed(Duration(seconds: 2)); // Simulating network delay

      // Mock API response (replace with actual API call later)
      courses.value = ["Computer Science", "Mathematics", "Physics"];
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch modules!");
    } finally {
      isLoadingCourses.value = false;
    }
  }

  // Function to send announcement
  void sendAnnouncement() {
    if (selectedCourse.value == null ||
        title.value.isEmpty ||
        content.value.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required!",
        backgroundColor: Colors.red,
      );
      return;
    }

    isSending.value = true;

    // Simulate API request
    Future.delayed(Duration(seconds: 2), () {
      isSending.value = false;

      // Create announcement object
      var newAnnouncement = Announcement(
        course: selectedCourse.value!,
        title: title.value,
        content: content.value,
        createdAt: DateTime.now(),
      );

      // Save announcement
      announcements.add(newAnnouncement);

      Get.snackbar(
        "Success",
        "Announcement sent successfully!",
        backgroundColor: Colors.green,
      );
      clearFields();
    });
  }

  // Clear input fields
  void clearFields() {
    selectedCourse.value = null;
    titleController.clear();
    contentController.clear();
  }
}
