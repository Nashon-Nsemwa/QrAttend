import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qrattend/models/Student.dart';

class LectureAttendanceController extends GetxController {
  // Module and filter states
  var selectedModule = RxnString(null);
  var searchQuery = ''.obs;
  var selectedFilter = 'Recent'.obs;

  // Loading and data states
  var isLoading = false.obs;
  var students = <Student>[].obs;

  var filteredStudents = <Student>[].obs;
  var activeFilter = "Recent Attendance".obs;

  // Hardcoded modules list
  final List<String> _hardcodedModules = [
    'Math',
    'Physics',
    'Computer Science',
  ];

  // List for dynamically fetched modules (but hardcoded)
  var modules = <String>[].obs;

  // Mock student attendance data (with dates and module data)
  final List<Student> allStudents = [
    Student(
      name: "John Doe",
      registrationNumber: "12345",
      isPresent: true,
      date: DateTime(2025, 2, 16),
      module: 'Math',
    ),
    Student(
      name: "Jane Smith",
      registrationNumber: "67890",
      isPresent: false,
      date: DateTime(2025, 2, 15),
      module: 'Physics',
    ),
    Student(
      name: "Mike Johnson",
      registrationNumber: "11223",
      isPresent: true,
      date: DateTime(2025, 2, 9),
      module: 'Computer Science',
    ),
    Student(
      name: "Anna Brown",
      registrationNumber: "44556",
      isPresent: false,
      date: DateTime(2025, 1, 27),
      module: 'Math',
    ),
    Student(
      name: "Chris Evans",
      registrationNumber: "77889",
      isPresent: true,
      date: DateTime(2025, 1, 16),
      module: 'Physics',
    ),
  ];

  // Dynamically generate date filters based on selected module
  List<String> get dateFilters {
    Set<String> uniqueDates = {};
    if (selectedModule.value != null) {
      for (var student in allStudents) {
        if (student.module == selectedModule.value) {
          uniqueDates.add(DateFormat('yyyy-MM-dd').format(student.date));
        }
      }
    }
    return uniqueDates.toList();
  }

  // Dynamically get the most recent date based on the selected module
  String get defaultDate {
    if (selectedModule.value == null) return '';

    List<DateTime> dates = [];
    for (var student in allStudents) {
      if (student.module == selectedModule.value) {
        dates.add(student.date);
      }
    }
    dates.sort(
      (a, b) => b.compareTo(a),
    ); // Sort dates in descending order (most recent first)
    return DateFormat(
      'yyyy-MM-dd',
    ).format(dates.isNotEmpty ? dates.first : DateTime.now());
  }

  @override
  void onInit() {
    super.onInit();
    fetchModules(); // Fetch modules (though they are hardcoded) on initialization
  }

  // Fetch modules (hardcoded but simulating fetch)
  void fetchModules() {
    // Simulate network delay
    modules.value = _hardcodedModules; // Set hardcoded modules list
  }

  // Fetch attendance data (mock API call)
  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
      students.value =
          allStudents.where((student) {
            return selectedModule.value == null ||
                student.module == selectedModule.value;
          }).toList(); // Filter by selected module
      applyFilter(selectedFilter.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Select module with loading indication
  void selectModule(String? module) {
    selectedModule.value = module;
    fetchAttendance(); // Show loading progress only after module is selected
  }

  // Search logic
  void searchStudents(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      applyFilter(selectedFilter.value); // Reapply filter after search clears
    } else {
      filteredStudents.value =
          students
              .where(
                (student) =>
                    student.name.toLowerCase().contains(query.toLowerCase()) ||
                    student.registrationNumber.contains(query),
              )
              .toList();
    }
  }

  // Date-based Filter logic (updated to use dynamic date filters)
  void applyFilter(String filter) {
    selectedFilter.value = filter;

    filteredStudents.value =
        students.where((student) {
          bool matchesModule =
              selectedModule.value == null ||
              student.module == selectedModule.value;
          bool matchesFilter = false;

          // Dynamically check if the student's date matches the selected filter
          if (filter == "Recent") {
            matchesFilter = true; // Show all attendance
          } else {
            matchesFilter =
                DateFormat('yyyy-MM-dd').format(student.date) == filter;
          }

          return matchesModule && matchesFilter;
        }).toList();

    // If no records found for the filter
    if (filteredStudents.isEmpty) {
      activeFilter.value = "No results for $filter";
    } else {
      activeFilter.value = "Showing: $filter Attendance";
    }
  }

  // Format date for display
  String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}
