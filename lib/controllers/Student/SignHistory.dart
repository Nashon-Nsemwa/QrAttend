import 'package:get/get.dart';
import 'package:qrattend/models/SignHistory.dart';

class SignHistoryController extends GetxController {
  // List of sign-in history
  var signHistoryList = <SignHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSignHistory();
  }

  // Simulate fetching data from backend
  void fetchSignHistory() {
    // Mock data (replace this with your API call)
    List<SignHistoryModel> history = [
      SignHistoryModel(
        courseCode: "CS101",
        timeSigned: "08:30 AM",
        status: "Signed",
      ),
      SignHistoryModel(
        courseCode: "CS203",
        timeSigned: "10:00 AM",
        status: "Signed",
      ),
      SignHistoryModel(
        courseCode: "CS305",
        timeSigned: "01:15 PM",
        status: "Signed",
      ),
      SignHistoryModel(
        courseCode: "CS402",
        timeSigned: "03:45 PM",
        status: "Signed",
      ),
    ];

    signHistoryList.assignAll(history);
  }
}
