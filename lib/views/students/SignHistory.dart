import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/controllers/Student/SignHistory.dart';
import 'package:qrattend/models/SignHistory.dart';

class SignHistory extends StatelessWidget {
  final SignHistoryController controller = Get.find();

  SignHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(() {
          if (controller.signHistoryList.isEmpty) {
            return const Center(
              child: Text(
                "No sign-in history available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Displaying sign-in history as simple ListTiles
          return ListView.builder(
            itemCount: controller.signHistoryList.length,
            itemBuilder: (context, index) {
              SignHistoryModel sign = controller.signHistoryList[index];
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  sign.courseCode,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Time Signed: ${sign.timeSigned}"),
                trailing: Text(
                  sign.status,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
