import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/controllers/Lecture/LectureAttendanceControler.dart';
import 'package:qrattend/controllers/Shared/UserSessionController.dart';

class LectureAttendance extends StatelessWidget {
  final LectureAttendanceController controller = Get.find();
  final UserSessionController sessionController = Get.find();

  LectureAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                )
                : RefreshIndicator(
                  onRefresh: controller.fetchAttendance,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        // Module Dropdown Selector (Show first)
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Select Module",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          value: controller.selectedModule.value,
                          items:
                              controller.modules.map((String module) {
                                return DropdownMenuItem<String>(
                                  value: module,
                                  child: Text(module),
                                );
                              }).toList(),
                          onChanged: (value) {
                            controller.selectedModule.value = value;
                            controller
                                .fetchAttendance(); // Refresh attendance data
                          },
                        ),
                        const SizedBox(height: 20),

                        // Show content only when module is selected
                        if (controller.selectedModule.value != null) ...[
                          // Search Bar + Filter Row
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: TextEditingController(),
                                  cursorColor: Colors.blue,
                                  decoration: InputDecoration(
                                    focusColor: Colors.blue,
                                    prefixIcon: const Icon(Icons.search),
                                    hintText: "Search by name or reg no.",
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: controller.searchStudents,
                                ),
                              ),
                              const SizedBox(width: 10),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.filter_alt_rounded,
                                  size: 35,
                                ),
                                onSelected: controller.applyFilter,
                                itemBuilder: (context) {
                                  // Dynamically generate PopupMenuItems based on the selected module
                                  return controller.dateFilters.map((date) {
                                    return PopupMenuItem<String>(
                                      value: date,
                                      child: Text(date),
                                    );
                                  }).toList();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Show active filter message
                          Text(
                            controller.activeFilter.value,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // TabBar for Present & Absent
                          DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Container(
                                  color: theme.onSecondary,
                                  child: const TabBar(
                                    labelStyle: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    tabs: [
                                      Tab(text: 'Present'),
                                      Tab(text: 'Absent'),
                                    ],
                                    indicatorColor: Colors.blue,
                                  ),
                                ),
                                SizedBox(
                                  height: 400,
                                  child: TabBarView(
                                    children: [
                                      // Present Tab Content
                                      Obx(() => _buildStudentList(true)),
                                      // Absent Tab Content
                                      Obx(() => _buildStudentList(false)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  // Student List Builder
  Widget _buildStudentList(bool isPresent) {
    final filteredList =
        controller.filteredStudents
            .where((student) => student.isPresent == isPresent)
            .toList();

    if (filteredList.isEmpty) {
      return const Center(child: Text("No records found"));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final student = filteredList[index];
        return ListTile(
          title: Text(student.name),
          subtitle: Text(
            "Reg No: ${student.registrationNumber} - Date: ${controller.formatDate(student.date)}",
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: isPresent ? Colors.green : Colors.red,
          ),
          onTap: () {
            final role = sessionController.role.value;
            if (role == UserRole.student) {
              Get.toNamed("/StudentAttendance");
            } else if (role == UserRole.lecturer) {
              Get.toNamed("/StudentAttendance");
            }
            Get.snackbar(
              "Student Selected",
              "${student.name}'s attendance details",
            );
          },
        );
      },
    );
  }
}
