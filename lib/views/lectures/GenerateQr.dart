import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrattend/controllers/Lecture/GenerateQrControler.dart';
import 'package:qrattend/controllers/Lecture/SaveShareController.dart';
import 'package:qrattend/models/GenerateQrCodeData.dart';
import 'package:screenshot/screenshot.dart';

class GenerateQr extends StatelessWidget {
  final GenerateQrController controller = Get.put(GenerateQrController());
  final SaveShareController _saveShareController = Get.put(
    SaveShareController(),
  );

  GenerateQr({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomSheet(context);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.onSecondaryFixed,
        title: const Text(
          "Generate QR Code",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showBottomSheet(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/generateqr.svg',
              height: 24,
              color: theme.onPrimary,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.generatedText.value.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Countdown timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.remainingTime.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Screenshot wrapper
                  Screenshot(
                    controller: _saveShareController.screenshotController,
                    child: Column(
                      children: [
                        // QR Code Display
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 12,
                                spreadRadius: 3,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: controller.generatedText.value,
                            version: QrVersions.auto,
                            size: 250,
                            backgroundColor: Colors.white,
                            // Change background
                            eyeStyle: const QrEyeStyle(
                              // Customize QR "eyes"
                              eyeShape: QrEyeShape.circle,
                              color: Colors.blue,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              // Style data modules
                              dataModuleShape: QrDataModuleShape.circle,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // QR Details Card
                        SizedBox(
                          width: 300,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _detailRow(
                                    "Course",
                                    controller.selectedCourse.value,
                                  ),
                                  _detailRow(
                                    "Module",
                                    controller.selectedModule.value,
                                  ),
                                  _detailRow(
                                    "Generated on",
                                    controller.getFormattedDate(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Share and Save Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _saveShareController.shareQRCode(),
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _saveShareController.saveQRCode(),
                        icon: const Icon(Icons.save),
                        label: const Text("Save"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          // Placeholder UI
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, size: 80, color: Colors.blue.shade300),
                const SizedBox(height: 16),
                const Text(
                  "Prepare your QR code setup!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  // Helper method for QR info row
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      backgroundColor: theme.onSecondary,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Course dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Obx(() {
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        value:
                            controller.selectedCourse.value.isEmpty
                                ? null
                                : controller.selectedCourse.value,
                        hint: const Text("Select Course"),
                        items:
                            controller.coursesWithModules.keys
                                .map(
                                  (course) => DropdownMenuItem(
                                    value: course,
                                    child: Text(course),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          controller.selectedCourse.value = value ?? '';
                          controller.selectedModule.value =
                              ''; // Reset module when course changes
                        },
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {
                      List<QRCode> active = controller.getActiveQRs();
                      if (active.isEmpty) {
                        Get.snackbar(
                          "History",
                          "All QR codes are expired.",
                          backgroundColor: Colors.orange,
                        );
                      } else {
                        Get.dialog(
                          AlertDialog(
                            title: const Text("Active QR Codes"),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: 300,
                              child: ListView.builder(
                                itemCount: active.length,
                                itemBuilder: (context, index) {
                                  final qr = active[index];
                                  return ListTile(
                                    title: Text("Module: ${qr.module}"),
                                    subtitle: Text(
                                      "Expires: ${qr.expirationTime}",
                                    ),
                                    trailing: const Icon(Icons.qr_code),
                                    onTap: () {
                                      controller.loadSelectedQRCode(qr);
                                      Get.back(); // Close dialog
                                      Navigator.of(
                                        context,
                                      ).pop(); // Close the bottom sheet
                                    },
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text(
                                  "Close",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "History",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Module dropdown (linked to selected course)
              Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  value:
                      controller.selectedModule.value.isEmpty
                          ? null
                          : controller.selectedModule.value,
                  hint: const Text("Select Module"),
                  items:
                      controller
                          .getModulesForSelectedCourse()
                          .map(
                            (module) => DropdownMenuItem(
                              value: module,
                              child: Text(module),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null && value.isNotEmpty) {
                      // Check if module already has an active QR
                      bool isActive = controller.isModuleActive(value);

                      if (isActive) {
                        Get.snackbar(
                          "QR Still Active",
                          "The QR for this module is still active. Please check History.",

                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                      } else {
                        // Update the selected module without closing the modal
                        controller.selectedModule.value = value;
                      }
                    }
                  },
                );
              }),

              const SizedBox(height: 16),

              // Duration dropdown
              Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  value:
                      controller.selectedDuration.value.isEmpty
                          ? null
                          : controller.selectedDuration.value,
                  hint: const Text("Select Duration"),
                  items:
                      controller.durations
                          .map(
                            (duration) => DropdownMenuItem(
                              value: duration,
                              child: Text(duration),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    controller.selectedDuration.value = value ?? '';
                  },
                );
              }),

              const SizedBox(height: 24),

              // Generate QR Button
              Obx(() {
                return ElevatedButton.icon(
                  onPressed:
                      controller.selectedCourse.value.isNotEmpty &&
                              controller.selectedModule.value.isNotEmpty &&
                              controller.selectedDuration.value.isNotEmpty &&
                              !controller.isModuleActive(
                                controller.selectedModule.value,
                              )
                          ? () {
                            controller.generateQRCode();
                            Navigator.pop(context); // Close modal after success
                          }
                          : null,
                  icon: const Icon(Icons.qr_code, color: Colors.white),
                  label: const Text(
                    'Generate QR Code',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(
                      double.infinity,
                      50,
                    ), // Make the button width expand to full width of the modal
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // You already have _showBottomSheet method below this
}
