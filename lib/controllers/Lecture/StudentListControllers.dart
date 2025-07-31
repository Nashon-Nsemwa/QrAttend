import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/studentList.dart';

class StudentListController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String lectureId = FirebaseAuth.instance.currentUser?.uid ?? '';

  var selectedCourse = ''.obs; // e.g. "Computer Science Year 1"
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
    ever(selectedCourse, (value) {
      if (value.isNotEmpty) fetchModules(value);
    });
    everAll([selectedCourse, selectedModule], (_) {
      if (selectedCourse.value.isNotEmpty && selectedModule.value.isNotEmpty) {
        fetchStudents();
      }
    });
  }

  /// 🔥 Load lecturer's courses (as concatenated strings)
  void fetchMockCourses() async {
    isLoading.value = true;
    try {
      final lectureDoc =
          await firestore.collection('lectures').doc(lectureId).get();

      if (!lectureDoc.exists) throw Exception("Lecture document not found.");

      final lectureData = lectureDoc.data();
      final List<dynamic> lectureCourseList =
          lectureData?['details']?['courses'] ?? [];

      final Set<String> courseNames = {};

      for (String fullCourse in lectureCourseList) {
        courseNames.add(fullCourse); // Already in "Course Year X" format
      }

      courses.assignAll(courseNames.toList());
      modules.clear();
      selectedCourse.value = '';
      selectedModule.value = '';
    } catch (e) {
      Get.snackbar(
        "Loading Error",
        "Failed to load courses. Please try again later.\n$e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔁 Fetch modules by splitting selectedCourse
  void fetchModules(String concatenatedCourse) async {
    isLoading.value = true;
    selectedModule.value = '';
    modules.clear();

    try {
      final parts = concatenatedCourse.trim().split(' ');
      if (parts.length < 3) {
        Get.snackbar("Invalid Format", "Course format is invalid.");
        return;
      }

      final year = parts.sublist(parts.length - 2).join(' '); // "Year X"
      final name = parts.sublist(0, parts.length - 2).join(' '); // course name

      final courseQuery =
          await firestore
              .collection('courses')
              .where('name', isEqualTo: name)
              .where('year', isEqualTo: year)
              .limit(1)
              .get();

      if (courseQuery.docs.isEmpty) {
        Get.snackbar("Not Found", "Course not found.");
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
        "Unable to fetch modules.\n$e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🧠 Fetch students for selected course+module
  void fetchStudents() async {
    isLoading.value = true;
    allStudents.clear();
    filteredStudents.clear();

    try {
      final parts = selectedCourse.value.trim().split(' ');
      if (parts.length < 3) {
        Get.snackbar("Invalid Format", "Selected course is invalid.");
        return;
      }

      final year = parts.sublist(parts.length - 2).join(' ');
      final name = parts.sublist(0, parts.length - 2).join(' ');

      final courseQuery =
          await firestore
              .collection('courses')
              .where('name', isEqualTo: name)
              .where('year', isEqualTo: year)
              .limit(1)
              .get();

      if (courseQuery.docs.isEmpty) {
        Get.snackbar("Course Error", "Course not found.");
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
        Get.snackbar("Module Error", "Module not found.");
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
        "Failed to fetch students.\n$e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterStudents() {
    final query = searchQuery.value.toLowerCase();
    filteredStudents.value =
        allStudents.where((student) {
          return (student.name.toLowerCase().contains(query) ||
                  student.regNo.toLowerCase().contains(query)) &&
              student.module == selectedModule.value;
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
