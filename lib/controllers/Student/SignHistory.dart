import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/SignHistory.dart';
import 'package:intl/intl.dart';

class SignHistoryController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';

  var signHistoryList = <SignHistoryModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSignHistory();
  }

  Future<void> fetchSignHistory() async {
    isLoading.value = true;
    signHistoryList.clear();

    try {
      // Get student document
      final studentDoc =
          await firestore.collection('students').doc(studentId).get();
      if (!studentDoc.exists) {
        isLoading.value = false;
        return;
      }

      final String courseName = studentDoc['course'];

      // Find course document
      final courseQuery =
          await firestore
              .collection('courses')
              .where('name', isEqualTo: courseName)
              .get();
      if (courseQuery.docs.isEmpty) {
        isLoading.value = false;
        return;
      }

      final courseDoc = courseQuery.docs.first;
      final courseId = courseDoc.id;

      // Get all modules for this course
      final modulesQuery =
          await firestore
              .collection('courses')
              .doc(courseId)
              .collection('modules')
              .get();

      List<SignHistoryModel> history = [];

      for (var moduleDoc in modulesQuery.docs) {
        final moduleId = moduleDoc.id;
        final moduleCode = moduleDoc['code'] ?? '';

        // Get attendance docs for this module
        final attendanceDocs =
            await firestore
                .collection('courses')
                .doc(courseId)
                .collection('modules')
                .doc(moduleId)
                .collection('attendance')
                .get();

        for (var attDoc in attendanceDocs.docs) {
          final data = attDoc.data();

          // Check if student signed in on that day
          final studentsMap = data['students'] ?? {};
          if (studentsMap.containsKey(studentId)) {
            final studentAttendance = studentsMap[studentId];
            Timestamp? lastUpdatedTimestamp = studentAttendance['lastUpdated'];

            String timeSigned = "Unknown";
            String dateSigned = attDoc.id.replaceFirst('att_', '');
            // Convert attDoc id "att_yyyyMMdd" to a date format
            try {
              DateTime date = DateTime.parse(
                '${dateSigned.substring(0, 4)}-${dateSigned.substring(4, 6)}-${dateSigned.substring(6, 8)}',
              );
              dateSigned = DateFormat('yyyy-MM-dd').format(date);
            } catch (_) {}

            if (lastUpdatedTimestamp != null) {
              timeSigned = DateFormat(
                'hh:mm a',
              ).format(lastUpdatedTimestamp.toDate());
            }

            history.add(
              SignHistoryModel(
                moduleCode: moduleCode,
                timeSigned: "$dateSigned at $timeSigned",
                status: "Signed",
              ),
            );
          }
        }
      }

      // Sort by date & time descending
      history.sort((a, b) => b.timeSigned.compareTo(a.timeSigned));

      signHistoryList.assignAll(history);
    } catch (e) {
      Get.snackbar('error', '$e');
      signHistoryList.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
