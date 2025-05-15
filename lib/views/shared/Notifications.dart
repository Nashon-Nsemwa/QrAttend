import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/controllers/Shared/NotificationController%20.dart';
import 'package:qrattend/models/Notification.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());
    final theme = Theme.of(context).colorScheme;
    return Obx(
      () => Scaffold(
        appBar:
            controller.selectedIndexes.isNotEmpty
                ? _buildSelectionAppBar(controller)
                : AppBar(
                  title: Text(
                    "Notifications",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: theme.onSecondaryFixed,
                ),

        body: Padding(
          padding: EdgeInsets.all(16),
          child: Obx(() {
            if (controller.notifications.isEmpty) {
              return _buildNoNotifications();
            }

            return ListView.builder(
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final NotificationModel notification =
                    controller.notifications[index];
                bool isSelected = controller.selectedIndexes.contains(index);

                return GestureDetector(
                  onLongPress: () => controller.toggleSelection(index),
                  onTap: () {
                    if (controller.selectedIndexes.isNotEmpty) {
                      controller.toggleSelection(index);
                    }
                  },
                  child: Card(
                    elevation: 3,
                    color:
                        isSelected
                            ? Colors.blue.withOpacity(0.2)
                            : theme.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        "From: ${notification.from}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isSelected ? Colors.blue : Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isSelected ? Colors.blue : theme.onPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            notification.content,
                            style: TextStyle(color: theme.onPrimary),
                          ),
                        ],
                      ),
                      trailing: Text(
                        notification.time,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  AppBar _buildSelectionAppBar(NotificationController controller) {
    return AppBar(
      title: Text("${controller.selectedIndexes.length} Selected"),
      backgroundColor: Colors.blueAccent,
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: controller.clearSelection,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.copy),
          onPressed: controller.copySelectedNotifications,
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: controller.deleteSelectedNotifications,
        ),
      ],
    );
  }

  Widget _buildNoNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No notifications available",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
