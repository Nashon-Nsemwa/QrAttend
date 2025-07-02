import 'package:get/get.dart';
import 'package:qrattend/models/Schedule.dart';

class CourseYear {
  final String name;
  final String year;
  CourseYear({required this.name, required this.year});
}

class LectureScheduleController extends GetxController {
  var selectedCourse = ''.obs;
  var selectedDay = "Monday".obs;
  final courses = <String>[].obs;
  final schedules = <String, Map<String, List<ScheduleItem>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
    fetchSchedule();
  }

  // Fetch courses taught by the lecturer, with year
  void fetchCourses() {
    // Example: fetched from API or database
    final courseYearList = [
      CourseYear(name: "ComputerScience", year: "1"),
      CourseYear(name: "Networking", year: "1"),
      CourseYear(name: "Networking", year: "2"),
      CourseYear(name: "Database", year: "1"),
    ];

    // Concatenate course name and year
    courses.assignAll(
      courseYearList.map((c) => "${c.name} ${c.year}").toList(),
    );
    selectedCourse.value = courses.first; // Set default course
  }

  // Fetch schedule for all courses
  void fetchSchedule() {
    schedules.value = {
      "ComputerScience 1": {
        "Monday": [
          ScheduleItem(
            type: "lecture",
            subject: "Introduction to Cryptography",
            time: "08:00 - 09:30",
            venue: "Room 201",
          ),
          ScheduleItem(
            type: "lecture",
            subject: "Hash Functions",
            time: "10:00 - 11:30",
            venue: "Room 202",
          ),
          ScheduleItem(
            type: "Break",
            subject: "Short Break",
            time: "10:00 - 11:30",
            venue: "",
          ),
        ],
        "Tuesday": [
          ScheduleItem(
            type: "lecture",
            subject: "Public Key Cryptography",
            time: "08:00 - 09:30",
            venue: "Room 201",
          ),
        ],
      },
      "Networking 1": {
        "Monday": [
          ScheduleItem(
            type: "lecture",
            subject: "Network Security",
            time: "12:00 - 13:30",
            venue: "Room 305",
          ),
        ],
        "Tuesday": [
          ScheduleItem(
            type: "lecture",
            subject: "TCP/IP Protocols",
            time: "10:00 - 11:30",
            venue: "Room 307",
          ),
        ],
      },
    };
  }

  // Change selected day
  void setSelectedDay(String day) {
    selectedDay.value = day;
  }

  // Change selected course
  void setSelectedCourse(String course) {
    selectedCourse.value = course;
  }
}
