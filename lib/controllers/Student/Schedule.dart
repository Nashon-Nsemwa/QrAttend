import 'package:get/get.dart';
import 'package:qrattend/models/Schedule.dart';
// import 'dart:convert';

class ScheduleController extends GetxController {
  var selectedDay = "Monday".obs;
  final schedules = <String, List<ScheduleItem>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSchedule(); // Load data immediately on initialization
  }

  // 📲 Simulate backend fetch (mock data)
  void fetchSchedule() {
    schedules.value = {
      "Monday": [
        ScheduleItem(
          type: "lecture",
          subject: "Cryptography",
          time: "08:00 - 09:30",
          venue: "Room 101",
        ),
        ScheduleItem(
          type: "break",
          subject: "Break",
          time: "09:30 - 10:00",
          venue: "Cafeteria",
        ),
        ScheduleItem(
          type: "lecture",
          subject: "Networking",
          time: "10:00 - 11:30",
          venue: "Room 105",
        ),
        ScheduleItem(
          type: "lecture",
          subject: "Web based",
          time: "12:00 - 13:30",
          venue: "Room 105",
        ),
        ScheduleItem(
          type: "lecture",
          subject: "Database",
          time: "13:00 - 14:30",
          venue: "Room 105",
        ),
        ScheduleItem(
          type: "lecture",
          subject: "Programming",
          time: "14:00 - 15:30",
          venue: "Room 105",
        ),
      ],
      "Tuesday": [
        ScheduleItem(
          type: "lecture",
          subject: "Mathematics",
          time: "08:00 - 09:30",
          venue: "Room 102",
        ),
        ScheduleItem(
          type: "lecture",
          subject: "Programming",
          time: "10:00 - 11:30",
          venue: "Room 103",
        ),
      ],
    };
  }

  // 🌐 Backend Setup (Optional)
  // Future<void> fetchScheduleFromBackend() async {
  //   try {
  //     var response = await http.get(Uri.parse('https://yourapi.com/schedule'));
  //     if (response.statusCode == 200) {
  //       // Parse the response into schedule data
  //       var data = jsonDecode(response.body);
  //       schedules.value = data.map<String, List<ScheduleItem>>(
  //         (day, items) => MapEntry(
  //           day,
  //           (items as List).map((item) => ScheduleItem.fromJson(item)).toList(),
  //         ),
  //       );
  //     } else {
  //       throw Exception('Failed to load schedule');
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to fetch schedule");
  //   }
  // }

  // Change selected day
  void setSelectedDay(String day) {
    selectedDay.value = day;
  }
}
