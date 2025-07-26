import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrattend/models/Notification.dart';
import 'package:qrattend/services/NotificationServices.dart';

class NotificationController extends GetxController {
  // State variables
  var notifications = <NotificationModel>[].obs;
  var selectedIndexes = <int>{}.obs;
  var deletedItems = <NotificationModel>[].obs;
  var deletedIndexes = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(); // Simulate backend fetch without UI delay
    NotificationService.requestPermissions();
  }

  // Simulate backend data fetch instantly (no delay)
  void fetchNotifications() {
    notifications.value = [
      NotificationModel(
        from: "Admin",
        title: "Class Rescheduled",
        content: "Your class has been moved to 10:00 AM.",
        time: "10:15 AM",
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      NotificationModel(
        from: "System",
        title: "Attendance Recorded",
        content: "Your attendance has been successfully recorded.",
        time: "9:45 AM",
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        from: "Lecturer",
        title: "Assignment Due",
        content: "Submit your assignment by 5 PM today.",
        time: "8:30 AM",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        from: "University",
        title: "Fee Reminder",
        content: "Your semester fees are due next week.",
        time: "Yesterday",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]..sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    ); // Initial sort by time
  }

  // Toggle selection of a notification
  void toggleSelection(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      selectedIndexes.add(index);
    }
  }

  // Clear selected notifications
  void clearSelection() => selectedIndexes.clear();

  void deleteSelectedNotifications() {
    if (selectedIndexes.isEmpty) return;

    // Filter out invalid indexes first
    final validIndexes =
        selectedIndexes
            .where((index) => index >= 0 && index < notifications.length)
            .toList();

    if (validIndexes.isEmpty) {
      selectedIndexes.clear();
      return;
    }

    // Save deleted notifications temporarily
    deletedItems.value =
        validIndexes.map((index) => notifications[index]).toList();
    deletedIndexes.value = validIndexes.toList()..sort();

    // Remove the selected notifications
    notifications.removeWhere(
      (notification) =>
          validIndexes.contains(notifications.indexOf(notification)),
    );

    selectedIndexes.clear();

    // Show Undo Snackbar
    Get.snackbar(
      "Deleted",
      "${deletedItems.length} notification(s) deleted",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          undoDelete();
        },
        child: const Text("Undo", style: TextStyle(color: Colors.white)),
      ),
      duration: const Duration(seconds: 5),
    );
  }

  void undoDelete() {
    if (deletedItems.isEmpty || deletedIndexes.isEmpty) return;

    // Add back all deleted items
    notifications.addAll(deletedItems);

    // Sort all notifications by timestamp (newest first)
    notifications.value =
        notifications.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Show success message
    Get.snackbar(
      "Undo",
      "Notifications restored and sorted by time!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    );

    // Clear the undo history
    deletedItems.clear();
    deletedIndexes.clear();
  }

  // Copy selected notifications to clipboard
  void copySelectedNotifications() {
    if (selectedIndexes.isEmpty) return;

    String copiedText = selectedIndexes
        .map((index) {
          final notification = notifications[index];
          return "From: ${notification.from}\nTitle: ${notification.title}\nContent: ${notification.content}\nTime: ${notification.time}\n";
        })
        .join("\n-----------------\n");

    Clipboard.setData(ClipboardData(text: copiedText)).then((_) {
      Get.snackbar(
        "Copied",
        "Notifications copied to clipboard",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
      );
    });

    clearSelection();
  }

  // Helper method to sort notifications by time
  void sortByTime() {
    notifications.value =
        notifications.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
