import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qrattend/utils/CustomeScandialog.dart';

class QRScanController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  var isFlashOn = false.obs;
  var isImagePickerActive = false.obs;
  var isQRCodeScanned = false.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
    scannerController.toggleTorch();
  }

  void switchCamera() {
    scannerController.switchCamera();
  }

  void handleQRScan(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      String? scannedCode = barcodes.first.rawValue;

      if (!isQRCodeScanned.value) {
        isQRCodeScanned.value = true;

        try {
          if (scannedCode == null) throw Exception("QR Code is empty");

          final qrData = jsonDecode(scannedCode);
          final String course = qrData['course'];
          final String module = qrData['module'];
          final DateTime expiration = DateTime.parse(qrData['expirationTime']);
          final double qrLatitude = qrData['latitude'];
          final double qrLongitude = qrData['longitude'];

          ScanDialog.showLoading();

          if (DateTime.now().isAfter(expiration)) {
            throw Exception("This QR Code has expired.");
          }

          final position = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout:
                () =>
                    throw Exception(
                      "Unable to get location. Please check your GPS.",
                    ),
          );

          final distance = Geolocator.distanceBetween(
            qrLatitude,
            qrLongitude,
            position.latitude,
            position.longitude,
          );

          if (distance > 100) {
            throw Exception(
              "You are ${distance.toStringAsFixed(2)} meters away. Please move closer.",
            );
          }

          final studentQuery =
              await firestore
                  .collection('students')
                  .where('name', isEqualTo: 'Nelson Nsemwa')
                  .limit(1)
                  .get();

          if (studentQuery.docs.isEmpty) {
            throw Exception("Student 'Nelson Nsemwa' not found.");
          }

          final studentDoc = studentQuery.docs.first;
          final studentId = studentDoc.id;
          final studentName = studentDoc['name'];
          final studentCourse = studentDoc['course'];

          if (studentCourse != course) {
            throw Exception("You are not registered in the course '$course'.");
          }

          final courseQuery =
              await firestore
                  .collection('courses')
                  .where('name', isEqualTo: course)
                  .limit(1)
                  .get();
          if (courseQuery.docs.isEmpty) {
            throw Exception("Course '$course' not found.");
          }

          final courseDoc = courseQuery.docs.first;

          final moduleQuery =
              await courseDoc.reference
                  .collection('modules')
                  .where('name', isEqualTo: module)
                  .limit(1)
                  .get();

          if (moduleQuery.docs.isEmpty) {
            throw Exception(
              "Module '$module' not found under course '$course'.",
            );
          }

          final moduleDoc = moduleQuery.docs.first;

          final attendanceCollection = moduleDoc.reference.collection(
            'attendance',
          );
          final attendanceQuery =
              await attendanceCollection
                  .orderBy('createdOn', descending: true)
                  .limit(1)
                  .get();

          if (attendanceQuery.docs.isEmpty) {
            throw Exception("Attendance session has not been opened yet.");
          }

          final attendanceDoc = attendanceQuery.docs.first;
          final attendanceRef = attendanceDoc.reference;

          final attendanceData = attendanceDoc.data();
          final Map<String, dynamic> studentsMap = Map<String, dynamic>.from(
            attendanceData['students'] ?? {},
          );

          int attended = 1;
          if (studentsMap.containsKey(studentId)) {
            attended = (studentsMap[studentId]['attended'] ?? 0) + 1;
          }

          final totalClasses = attendanceData['totalclasses'] ?? 1;
          final percentage = (attended / totalClasses) * 100;

          await attendanceRef.set({
            'students.$studentId': {
              'name': studentName,
              'attended': attended,
              'percentage': percentage,
              'lastUpdated': FieldValue.serverTimestamp(),
            },
          }, SetOptions(merge: true));

          ScanDialog.showResult(
            success: true,
            message:
                "You're within ${distance.toStringAsFixed(2)} meters. Attendance marked!",
          );
        } catch (e) {
          String msg = "Something went wrong. Please try again.";
          final err = e.toString();

          if (err.contains("expired")) {
            msg = "The QR code has expired.";
          } else if (err.contains("location") || err.contains("GPS")) {
            msg = "Failed to get your location.";
          } else if (err.contains("not found")) {
            msg = err;
          } else if (err.contains("closer")) {
            msg = err;
          } else if (err.contains("course") || err.contains("module")) {
            msg = err;
          } else if (err.contains("Attendance session has not been opened")) {
            msg = err;
          }

          ScanDialog.showResult(success: false, message: msg);
        }

        Future.delayed(const Duration(seconds: 2), () {
          isQRCodeScanned.value = false;
        });
      }
    } else {
      if (!isQRCodeScanned.value) {
        ScanDialog.showResult(success: false, message: "No QR code detected.");
      }
    }
  }

  Future<void> pickImageFromGallery() async {
    if (isImagePickerActive.value) {
      Get.snackbar("Notice", "Image picker is already in use.");
      return;
    }

    isImagePickerActive.value = true;

    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final capture = await scannerController.analyzeImage(image.path);
        final barcodes = capture?.barcodes;
        if (barcodes != null && barcodes.isNotEmpty) {
          handleQRScan(capture!);
        } else {
          ScanDialog.showResult(
            success: false,
            message: "No QR code found in the selected image.",
          );
        }
      }
    } catch (e) {
      ScanDialog.showResult(
        success: false,
        message: "Failed to process image. Try again.",
      );
    } finally {
      isImagePickerActive.value = false;
    }
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}
