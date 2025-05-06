import 'package:get/get.dart';
import 'package:qrattend/models/studentList.dart';

class StudentListController extends GetxController {
  var selectedCourse = ''.obs;
  var selectedModule = ''.obs;
  var searchQuery = ''.obs;

  var courses = ["BSc CS", "BSc IT"].obs;
  var modules = <String>[].obs;
  var allStudents = <StudentList>[].obs;
  var filteredStudents = <StudentList>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMockCourses();
    ever(searchQuery, (_) => filterStudents());
  }

  void fetchMockCourses() {
    selectedCourse.value = courses[0];
    fetchModules(selectedCourse.value);
    fetchStudents();
  }

  void fetchModules(String course) {
    selectedModule.value = '';
    if (course == "BSc CS") {
      modules.value = ["Web", "DBMS", "AI"];
    } else {
      modules.value = ["Cloud", "IOT"];
    }
  }

  void fetchStudents() {
    if (selectedModule.value.isNotEmpty) {
      isLoading.value = true;
    }

    Future.delayed(const Duration(seconds: 2), () {
      allStudents.value = [
        StudentList(
          name: "Anna Kimaro",
          regNo: "CS101",
          course: "BSc CS",
          module: "Web",
          email: "anna.kimaro@example.com",
          year: "Year 2",
          isClassRep: true,
        ),
        StudentList(
          name: "James Lema",
          regNo: "CS102",
          course: "BSc CS",
          module: "AI",
          email: "james.lema@example.com",
          year: "Year 3",
          isClassRep: false,
        ),
        StudentList(
          name: "Aisha K",
          regNo: "IT301",
          course: "BSc IT",
          module: "Cloud",
          email: "aisha.k@example.com",
          year: "Year 1",
          isClassRep: false,
        ),
      ];
      filterStudents();
      isLoading.value = false;
    });
  }

  void filterStudents() {
    if (selectedModule.value.isEmpty) {
      filteredStudents.clear();
      return;
    }

    filteredStudents.value =
        allStudents.where((student) {
          bool courseMatch = student.course == selectedCourse.value;
          bool moduleMatch = student.module == selectedModule.value;
          bool searchMatch =
              student.name.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              student.regNo.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              );
          return courseMatch && moduleMatch && searchMatch;
        }).toList();
  }
}
