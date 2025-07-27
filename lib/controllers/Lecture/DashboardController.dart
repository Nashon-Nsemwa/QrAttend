// lecture_dashboard_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LectureDashboardController extends GetxController {
  var lectureName = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchLectureName();
    super.onInit();
  }

  void fetchLectureName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc =
          await FirebaseFirestore.instance
              .collection('lectures')
              .doc(uid)
              .get();
      if (doc.exists) {
        lectureName.value = doc['name'] ?? 'Unknown';
      }
    } catch (e) {
      Get.snackbar('Error', 'failed to fetch Lecturer name: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
