import 'package:get/get.dart';
import 'package:qrattend/models/studentAttendance.dart';

class AttendanceController extends GetxController {
  // Student name from API
  var studentName = "Loading...".obs;

  // List of modules
  var modules = <Module>[].obs;

  // Selected module
  var selectedModule = Rxn<Module>();

  // Attendance details
  var attendanceDetails = <AttendanceDetail>[].obs;

  // Attendance summary stats
  var totalClasses = 0.obs;
  var presentDays = 0.obs;
  var absentDays = 0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudentName();
    fetchModules();
  }

  // Fetch student name (simulate API call)
  void fetchStudentName() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    studentName.value = "John Doe"; // Placeholder — replace with API data
  }

  // Fetch modules (simulate API)
  void fetchModules() {
    modules.value = [
      Module(code: "CS101", name: "Computer Science", lecturer: "Dr. Smith"),
      Module(code: "MATH101", name: "Mathematics", lecturer: "Prof. John"),
    ];
  }

  // Fetch attendance details and summary (simulate API) and internet loading on the attendance details
  Future<void> fetchAttendance(Module module) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      attendanceDetails.value = [
        AttendanceDetail(date: "2025-03-10", status: "Present"),
        AttendanceDetail(date: "2025-03-11", status: "Absent"),
        AttendanceDetail(date: "2025-03-12", status: "Present"),
        AttendanceDetail(date: "2025-03-13", status: "Absent"),
        AttendanceDetail(date: "2025-03-14", status: "Present"),
      ];

      totalClasses.value = attendanceDetails.length;
      presentDays.value =
          attendanceDetails.where((a) => a.status == "Present").length;
      absentDays.value =
          attendanceDetails.where((a) => a.status == "Absent").length;
    } finally {
      isLoading.value = false;
    }
  }
}
