import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/controllers/Shared/StudentAttendance.dart';
import 'package:qrattend/models/studentAttendance.dart';

class StudentAttendance extends StatelessWidget {
  final AttendanceController controller = Get.find();

  StudentAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student's Name (Dynamic from API)
              Obx(
                () => Text(
                  controller.studentName.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Module dropdown
              Obx(() {
                return DropdownButtonFormField<Module>(
                  decoration: InputDecoration(
                    labelText: "Select a Module",
                    labelStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  isExpanded: true,
                  value: controller.selectedModule.value,
                  onChanged: (Module? newValue) {
                    if (newValue != null) {
                      controller.selectedModule.value = newValue;
                      controller.fetchAttendance(newValue);
                    }
                  },
                  items:
                      controller.modules.map((Module value) {
                        return DropdownMenuItem<Module>(
                          value: value,
                          child: Text(value.name),
                        );
                      }).toList(),
                );
              }),
              const SizedBox(height: 20),

              // Module Information
              Obx(() {
                final module = controller.selectedModule.value;
                if (module == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${module.code} - ${module.name}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Lecturer: ${module.lecturer}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),

              // Total Classes Display
              Obx(
                () => Text(
                  'Total Classes: ${controller.totalClasses.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Attendance Summary Section
              Obx(() {
                final module = controller.selectedModule.value;
                if (module == null) return const SizedBox.shrink();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: _buildAttendanceSummary(
                        'Present',
                        controller.presentDays.value,
                        Colors.green,
                      ),
                    ),
                    Flexible(
                      child: _buildAttendanceSummary(
                        'Absent',
                        controller.absentDays.value,
                        Colors.red,
                      ),
                    ),
                    Flexible(
                      child: _buildAttendanceSummary(
                        'Attendance',
                        controller.totalClasses.value > 0
                            ? ((controller.presentDays.value /
                                        controller.totalClasses.value) *
                                    100)
                                .round()
                            : 0,
                        Colors.blue,
                        isPercentage: true,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // Attendance Details Section
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Obx(() {
                  final module = controller.selectedModule.value;
                  if (controller.isLoading.value && module != null) {
                    // Show loading indicator while fetching
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.attendanceDetails.isEmpty) {
                    return const Center(
                      child: Text("No attendance records available"),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.attendanceDetails.length,
                    itemBuilder: (context, index) {
                      final detail = controller.attendanceDetails[index];
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          leading: Icon(
                            detail.status == 'Present'
                                ? Icons.check_circle
                                : Icons.cancel,
                            color:
                                detail.status == 'Present'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                          title: Text(detail.date),
                          trailing: Text(
                            detail.status,
                            style: TextStyle(
                              color:
                                  detail.status == 'Present'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Summary helper widget
  Widget _buildAttendanceSummary(
    String title,
    int count,
    Color color, {
    bool isPercentage = false,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 30.0,
          child: Text(
            isPercentage ? '$count%' : '$count',
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
