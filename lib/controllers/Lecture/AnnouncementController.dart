import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:qrattend/models/annoncementmodel.dart';

class AnnouncementController extends GetxController {
  var selectedCourse = RxnString();
  var title = ''.obs;
  var content = ''.obs;
  var isSending = false.obs;
  var announcements = <Announcement>[].obs;
  var courses = <String>[].obs;
  var isLoadingCourses = false.obs;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      isLoadingCourses.value = true;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      final doc =
          await FirebaseFirestore.instance
              .collection('lectures')
              .doc(uid)
              .get();

      if (doc.exists && doc.data()?['details'] != null) {
        final details = doc['details'];
        if (details['courses'] != null && details['courses'] is List) {
          List<dynamic> rawCourses = details['courses'];
          courses.value = rawCourses.map((e) => e.toString()).toList();
        } else {
          Get.snackbar("No Courses", "No courses found in your details.");
        }
      } else {
        Get.snackbar("Error", "Lecture details not found.");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load courses: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCourses.value = false;
    }
  }

  Future<void> sendAnnouncement() async {
    if (selectedCourse.value == null ||
        titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isSending.value = true;

    try {
      String courseYear = selectedCourse.value!.trim();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'sendLectureAnnouncement',
      );

      final result = await callable.call({
        "title": titleController.text.trim(),
        "body": contentController.text.trim(),
        "courseYear": courseYear,
      });

      // Save announcement in Firestore under sentMessages -> lectureMessages subcollection
      await FirebaseFirestore.instance.collection('lectureMessages').add({
        'id': uid,
        "course": courseYear,
        "title": titleController.text.trim(),
        "content": contentController.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Success",
        result.data['message'] ?? "Announcement sent!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearFields();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send announcement: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  void clearFields() {
    selectedCourse.value = null;
    titleController.clear();
    contentController.clear();
  }
}
