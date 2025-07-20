import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattend/models/Student.dart';

class LectureAttendanceController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String lectureUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  var selectedModule = RxnString(null);
  var searchQuery = ''.obs;
  var selectedFilter = 'Recent'.obs;

  var isLoading = false.obs;
  var modules = <String>[].obs;
  var students = <Student>[].obs;
  var filteredStudents = <Student>[].obs;
  var activeFilter = "Recent Attendance".obs;

  Map<String, List<DateTime>> attendanceMap = {};
  List<String> allDates = [];

  @override
  void onInit() {
    super.onInit();
    fetchModules();
    everAll([selectedModule, selectedFilter], (_) => fetchAttendance());
  }

  /// ✅ Fetch modules from lecture's profile
  Future<void> fetchModules() async {
    isLoading.value = true;
    modules.clear();

    try {
      final doc = await firestore.collection('lectures').doc(lectureUid).get();
      if (!doc.exists) return;

      final data = doc.data();
      final details = data?['details'] ?? {};
      final lectureModules = List<String>.from(details['modules'] ?? []);
      modules.assignAll(lectureModules.toSet().toList());
    } catch (e) {
      Get.snackbar(
        "Error!",
        "Failed to fetch module",
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Fetch students who attended at least once
  Future<void> fetchAttendance() async {
    final moduleName = selectedModule.value;
    if (moduleName == null) return;

    isLoading.value = true;
    students.clear();
    attendanceMap.clear();

    try {
      DocumentSnapshot? moduleDoc;

      // 🔍 Find the module
      final coursesSnap = await firestore.collection('courses').get();
      for (var course in coursesSnap.docs) {
        final modulesSnap = await course.reference.collection('modules').get();
        for (var mod in modulesSnap.docs) {
          final modData = mod.data();
          if (modData['name'] == moduleName &&
              modData['lecturerUid'] == lectureUid) {
            moduleDoc = mod;
            break;
          }
        }
        if (moduleDoc != null) break;
      }

      if (moduleDoc == null) {
        Get.snackbar("Error", "Module not found");
        return;
      }

      // 📅 Get attendance records
      final attendanceSnap =
          await moduleDoc.reference
              .collection('attendance')
              .orderBy('createdOn', descending: true)
              .get();

      final List<DateTime> dateList = [];

      for (var doc in attendanceSnap.docs) {
        final Timestamp? ts = doc['createdOn'];
        final createdOn = ts?.toDate() ?? DateTime.now();
        dateList.add(createdOn);

        final Map<String, dynamic> studentMap = Map<String, dynamic>.from(
          doc['students'] ?? {},
        );

        for (var sid in studentMap.keys) {
          attendanceMap.putIfAbsent(sid, () => []).add(createdOn);
        }
      }

      // 📅 Extract and sort unique attendance dates
      allDates =
          dateList
              .map((d) => DateFormat('yyyy-MM-dd').format(d))
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a)); // descending order

      // 👤 Build a unique list of students who attended at least once
      final attendedStudentIds = attendanceMap.keys.toSet();
      if (attendedStudentIds.isEmpty) {
        students.clear();
        filteredStudents.clear();
        return;
      }

      final studentSnap =
          await firestore
              .collection('students')
              .where(FieldPath.documentId, whereIn: attendedStudentIds.toList())
              .get();

      final Map<String, Student> uniqueStudentsMap = {};

      for (var sDoc in studentSnap.docs) {
        final sid = sDoc.id;
        final sData = sDoc.data();
        final dates = attendanceMap[sid] ?? [];

        uniqueStudentsMap[sid] = Student(
          id: sid,
          name: sData['name'] ?? '',
          registrationNumber: sData['registrationNumber'] ?? '',
          isPresent: false, // Will be set during filtering
          date: dates.isEmpty ? DateTime.now() : dates.first,
          module: moduleName,
          attendanceDates: dates,
        );
      }

      students.assignAll(uniqueStudentsMap.values.toList());
      applyFilter(selectedFilter.value);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch attendance",
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Apply search + filter
  void searchStudents(String query) {
    searchQuery.value = query;
    applyFilter(selectedFilter.value);
  }

  /// ✅ Core filtering logic
  void applyFilter(String filter) {
    selectedFilter.value = filter;
    final qLower = searchQuery.value.toLowerCase();
    final String? formattedSelectedDate = filter == 'Recent' ? null : filter;

    final String? recentDate = allDates.isNotEmpty ? allDates.first : null;

    filteredStudents.value =
        students
            .map((s) {
              bool present = false;

              if (formattedSelectedDate != null) {
                present = s.attendanceDates.any(
                  (dt) =>
                      DateFormat('yyyy-MM-dd').format(dt) ==
                      formattedSelectedDate,
                );
              } else if (recentDate != null) {
                present = s.attendanceDates.any(
                  (dt) => DateFormat('yyyy-MM-dd').format(dt) == recentDate,
                );
              }

              return s.copyWith(isPresent: present);
            })
            .where(
              (s) =>
                  s.name.toLowerCase().contains(qLower) ||
                  s.registrationNumber.toLowerCase().contains(qLower),
            )
            .toList();

    activeFilter.value =
        filteredStudents.isEmpty
            ? "No records found"
            : (filter == 'Recent'
                ? "Showing Recent Attendance"
                : "Showing on $filter");
  }

  /// ✅ For dropdown
  List<String> get dateFilters => allDates;

  String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
}
