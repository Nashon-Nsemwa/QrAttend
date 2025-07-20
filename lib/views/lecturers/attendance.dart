import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/controllers/Lecture/LectureAttendanceControler.dart';
import 'package:qrattend/controllers/Shared/UserSessionController.dart';

class LectureAttendance extends StatefulWidget {
  LectureAttendance({Key? key}) : super(key: key);

  @override
  State<LectureAttendance> createState() => _LectureAttendanceState();
}

class _LectureAttendanceState extends State<LectureAttendance> {
  final LectureAttendanceController controller = Get.find();
  final UserSessionController sessionController = Get.find();

  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    // Persistent controller to keep the input stable
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAttendance,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
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
                    // Reset search input
                    searchController.clear();
                    controller.searchStudents('');
                    // Also fetch attendance on module change
                    controller.fetchAttendance();
                  },
                ),
                const SizedBox(height: 20),

                if (controller.selectedModule.value != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: searchController,
                          cursorColor: Colors.blue,
                          decoration: InputDecoration(
                            focusColor: Colors.blue,
                            prefixIcon: const Icon(Icons.search),
                            hintText: "Search by name or reg no.",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (val) => controller.searchStudents(val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.filter_alt_rounded, size: 35),
                        onSelected: (filter) {
                          controller.applyFilter(filter);
                        },
                        itemBuilder: (context) {
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

                  Text(
                    controller.activeFilter.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

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
                            tabs: [Tab(text: 'Present'), Tab(text: 'Absent')],
                            indicatorColor: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            children: [
                              Obx(() => _buildStudentList(true)),
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
        );
      }),
    );
  }

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
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final student = filteredList[index];
        return ListTile(
          title: Text(
            student.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Reg No: ${student.registrationNumber} "),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: isPresent ? Colors.green : Colors.red,
          ),
          onTap: () {
            Get.toNamed(
              "/StudentAttendance",
              arguments: {'studentId': student.id},
            );

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
