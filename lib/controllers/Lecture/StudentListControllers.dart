import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/studentList.dart';

class StudentListController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String lectureId = FirebaseAuth.instance.currentUser?.uid ?? '';

  var selectedCourse = ''.obs;
  var selectedModule = ''.obs;
  var searchQuery = ''.obs;

  var courses = <String>[].obs;
  var modules = <String>[].obs;
  var allStudents = <StudentList>[].obs;
  var filteredStudents = <StudentList>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMockCourses();
    ever(searchQuery, (_) => filterStudents());
    everAll([selectedCourse, selectedModule], (_) {
      if (selectedCourse.value.isNotEmpty && selectedModule.value.isNotEmpty) {
        fetchStudents();
      }
    });
  }

  /// 🔥 Load lecturer's courses and modules from Firebase
  void fetchMockCourses() async {
    isLoading.value = true;
    try {
      final attendanceSnaps =
          await firestore
              .collectionGroup('attendance')
              .where('students.$lectureId', isNotEqualTo: null)
              .get();

      final Set<String> courseNames = {};
      final Set<String> moduleNames = {};

      for (var doc in attendanceSnaps.docs) {
        final moduleId = doc.reference.parent.parent;
        moduleNames.add(moduleId?.id ?? '');

        final courseId = moduleId?.parent.parent?.id;
        if (courseId != null) {
          final courseDoc =
              await firestore.collection('courses').doc(courseId).get();
          if (courseDoc.exists) {
            courseNames.add(courseDoc['name']);
          }
        }
      }

      courses.assignAll(courseNames.toList());
      modules.clear();
      selectedCourse.value = '';
      selectedModule.value = '';
    } catch (e) {
      Get.snackbar(
        "Loading Error",
        "Failed to load courses and modules. Please check your connection or try again later.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔁 Updates `modules` list when course is selected
  void fetchModules(String course) async {
    isLoading.value = true;
    selectedModule.value = '';
    modules.clear();

    try {
      final courseQuery =
          await firestore
              .collection('courses')
              .where('name', isEqualTo: course)
              .limit(1)
              .get();

      if (courseQuery.docs.isEmpty) {
        Get.snackbar("Not Found", "Selected course could not be found.");
        return;
      }

      final courseDocId = courseQuery.docs.first.id;
      final moduleSnap =
          await firestore
              .collection('courses')
              .doc(courseDocId)
              .collection('modules')
              .get();

      modules.value =
          moduleSnap.docs
              .map((doc) => doc.data()['name'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
    } catch (e) {
      Get.snackbar(
        "Module Error",
        "Unable to fetch modules. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🧠 Fetch students who have attended the selected module at least once
  void fetchStudents() async {
    isLoading.value = true;
    allStudents.clear();
    filteredStudents.clear();

    try {
      final courseQuery =
          await firestore
              .collection('courses')
              .where('name', isEqualTo: selectedCourse.value)
              .limit(1)
              .get();

      if (courseQuery.docs.isEmpty) {
        Get.snackbar(
          "Course Error",
          "Course '${selectedCourse.value}' not found.",
        );
        return;
      }

      final courseDoc = courseQuery.docs.first;

      final moduleQuery =
          await courseDoc.reference
              .collection('modules')
              .where('name', isEqualTo: selectedModule.value)
              .limit(1)
              .get();

      if (moduleQuery.docs.isEmpty) {
        Get.snackbar(
          "Module Error",
          "Module '${selectedModule.value}' not found.",
        );
        return;
      }

      final moduleDoc = moduleQuery.docs.first;

      final attendanceSnap =
          await moduleDoc.reference.collection('attendance').get();
      final Set<String> uniqueStudentIds = {};

      for (var doc in attendanceSnap.docs) {
        final studentsMap = doc.data()['students'];
        if (studentsMap != null && studentsMap is Map<String, dynamic>) {
          uniqueStudentIds.addAll(studentsMap.keys);
        }
      }

      if (uniqueStudentIds.isEmpty) {
        Get.snackbar(
          "No Attendance",
          "No students have signed attendance for this module yet.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final chunks = _chunkList(uniqueStudentIds.toList(), 10);

      for (var chunk in chunks) {
        final studentSnap =
            await firestore
                .collection('students')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();

        final fetchedStudents =
            studentSnap.docs.map((doc) {
              final data = doc.data();
              return StudentList(
                id: doc.id,
                name: data['name'] ?? '',
                regNo: data['registrationNumber'] ?? '',
                course: data['course'] ?? '',
                module: selectedModule.value,
                email: data['email'] ?? '',
                year: data['year'] ?? '',
                isClassRep: data['isClassRep'] ?? false,
              );
            }).toList();

        allStudents.addAll(fetchedStudents);
      }

      final idsSeen = <String>{};
      allStudents.value =
          allStudents.where((student) {
            if (idsSeen.contains(student.id)) return false;
            idsSeen.add(student.id);
            return true;
          }).toList();

      filterStudents();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch student data. Please check your network or try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterStudents() {
    filteredStudents.value =
        allStudents.where((student) {
          final query = searchQuery.value.toLowerCase();
          return student.course == selectedCourse.value &&
              student.module == selectedModule.value &&
              (student.name.toLowerCase().contains(query) ||
                  student.regNo.toLowerCase().contains(query));
        }).toList();
  }

  List<List<String>> _chunkList(List<String> list, int limit) {
    List<List<String>> chunks = [];
    for (int i = 0; i < list.length; i += limit) {
      chunks.add(
        list.sublist(i, i + limit > list.length ? list.length : i + limit),
      );
    }
    return chunks;
  }
}
