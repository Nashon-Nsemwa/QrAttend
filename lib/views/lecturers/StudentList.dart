import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/controllers/Lecture/StudentListControllers.dart';

class StudentList extends StatelessWidget {
  final StudentListController controller = Get.find();

  StudentList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: controller.selectedCourse.value,
                decoration: InputDecoration(
                  labelText: "Select Course",
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                items:
                    controller.courses
                        .map(
                          (course) => DropdownMenuItem(
                            value: course,
                            child: Text(course),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  controller.selectedCourse.value = value!;
                  controller.fetchModules(value);
                  controller.filterStudents();
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Modules:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Module Choice Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      controller.modules
                          .map(
                            (module) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(module),
                                selected:
                                    controller.selectedModule.value == module,
                                selectedColor: Colors.blue,
                                onSelected: (selected) {
                                  controller.selectedModule.value =
                                      selected ? module : '';
                                  controller.isLoading.value = true;
                                  controller.fetchStudents();
                                },
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Search Field
              TextField(
                cursorColor: Colors.blue,
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: "Search by Reg No or Name",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Expanded List Section
              Expanded(
                child:
                    controller.selectedModule.value.isEmpty
                        ? const Center(
                          child: Text(
                            "Please select a module to view students.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                        : controller.isLoading.value
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                        : controller.filteredStudents.isEmpty
                        ? const Center(child: Text("No students found."))
                        : ListView.builder(
                          itemCount: controller.filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = controller.filteredStudents[index];
                            return Card(
                              color: theme.onSecondary,
                              elevation: 1,
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(child: Text(student.name)),
                                    if (student.isClassRep)
                                      Tooltip(
                                        message: "Class Rep",
                                        child: Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 18,
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text("Reg No: ${student.regNo}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    showStudentDetailsDialog(student, context);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showStudentDetailsDialog(student, BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    Get.dialog(
      Dialog(
        backgroundColor: theme.onSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 15),

                // Name with badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (student.isClassRep)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Tooltip(
                          message: "Class Representative",
                          child: Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Student Info Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      infoRow("Reg No:", student.regNo),
                      infoRow("Email:", student.email),
                      infoRow("Course:", student.course),
                      infoRow("Module:", student.module),
                      infoRow("Academic Year:", student.year),
                      infoRow("Class Rep:", student.isClassRep ? "Yes" : "No"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    label: const Text("Close"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
