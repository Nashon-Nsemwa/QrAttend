import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/studentAttendance.dart';

class AttendanceController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 🆕 Will use this for determining the target student
  late final String studentId;

  var studentName = "Loading...".obs;
  var modules = <Module>[].obs;
  var selectedModule = Rxn<Module>();

  var attendanceDetails = <AttendanceDetail>[].obs;
  var totalClasses = 0.obs;
  var presentDays = 0.obs;
  var absentDays = 0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();

    // 🔐 Determine which student we're viewing
    final argId = Get.arguments?['studentId'];
    studentId = argId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    fetchStudentName();
    fetchModules();
  }

  void fetchStudentName() async {
    final studentDoc =
        await firestore.collection('students').doc(studentId).get();
    if (studentDoc.exists) {
      studentName.value = studentDoc['name'] ?? "Unknown";
    } else {
      studentName.value = "Not Found";
    }
  }

  Future<void> fetchModules() async {
    isLoading.value = true;
    final studentDoc =
        await firestore.collection('students').doc(studentId).get();
    if (!studentDoc.exists) {
      isLoading.value = false;
      return;
    }

    final String courseName = studentDoc['course'];
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

    final modulesQuery =
        await firestore
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .get();

    modules.value =
        modulesQuery.docs
            .map((doc) => Module.fromFirestore(doc.id, doc.data(), courseId))
            .toList();

    isLoading.value = false;
  }

  Future<void> fetchAttendance(Module module) async {
    try {
      isLoading.value = true;

      final attendanceCollection = firestore
          .collection('courses')
          .doc(module.courseId)
          .collection('modules')
          .doc(module.id)
          .collection('attendance');

      final snapshots = await attendanceCollection.orderBy('createdOn').get();

      int attended = 0;
      List<AttendanceDetail> records = [];

      for (var doc in snapshots.docs) {
        final data = doc.data();
        final ts = data['createdOn'] as Timestamp?;
        final dateStr =
            ts != null
                ? DateFormat('yyyy-MM-dd').format(ts.toDate())
                : "Unknown";

        final studentsMap = data['students'] as Map<String, dynamic>? ?? {};
        final status =
            studentsMap.containsKey(studentId) ? "Present" : "Absent";
        if (status == "Present") attended++;

        records.add(AttendanceDetail(date: dateStr, status: status));
      }

      attendanceDetails.value = records;
      totalClasses.value = records.length;
      presentDays.value = attended;
      absentDays.value = totalClasses.value - presentDays.value;
    } catch (e) {
      print("Error fetching attendance: $e");
      totalClasses.value = 0;
      presentDays.value = 0;
      absentDays.value = 0;
      attendanceDetails.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
