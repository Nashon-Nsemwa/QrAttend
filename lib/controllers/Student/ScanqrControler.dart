import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> handleQRScan(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || isQRCodeScanned.value) return;

    isQRCodeScanned.value = true;
    String? scannedCode = barcodes.first.rawValue;

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

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null)
        throw Exception("You must be signed in to scan attendance.");

      final studentId = currentUser.uid;

      final studentDoc =
          await firestore.collection('students').doc(studentId).get();
      if (!studentDoc.exists) throw Exception("Student record not found.");

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

      if (courseQuery.docs.isEmpty) throw Exception("Course not found.");
      final courseDoc = courseQuery.docs.first;

      final moduleQuery =
          await courseDoc.reference
              .collection('modules')
              .where('name', isEqualTo: module)
              .limit(1)
              .get();

      if (moduleQuery.docs.isEmpty) throw Exception("Module not found.");
      final moduleDoc = moduleQuery.docs.first;

      final attendanceCollection = moduleDoc.reference.collection('attendance');

      final todayId =
          "att_${DateTime.now().toLocal().toString().split(' ')[0].replaceAll('-', '')}";
      final attendanceRef = attendanceCollection.doc(todayId);

      final attendanceSnap = await attendanceRef.get();
      final existingStudents = attendanceSnap.data()?['students'] ?? {};
      if (existingStudents.containsKey(studentId)) {
        throw Exception("You already signed in for today.");
      }

      // ✅ Mark today's attendance
      await attendanceRef.set({
        'createdOn': FieldValue.serverTimestamp(),
        'students': {
          studentId: {
            'name': studentName,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
        },
      }, SetOptions(merge: true));

      // ✅ Recalculate accurate summary (no increment)
      final allAttendanceDocs = await attendanceCollection.get();

      int totalClasses = allAttendanceDocs.docs.length;
      int attendedCount =
          allAttendanceDocs.docs.where((doc) {
            final studentsMap = doc.data()['students'] ?? {};
            return studentsMap.containsKey(studentId);
          }).length;

      double newPercentage =
          totalClasses == 0 ? 0 : (attendedCount / totalClasses) * 100;

      final summaryRef = moduleDoc.reference
          .collection('attendance_summary')
          .doc(studentId);

      await summaryRef.set({
        'name': studentName,
        'attended': attendedCount,
        'totalClasses': totalClasses,
        'percentage': newPercentage,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScanDialog.showResult(
        success: true,
        message:
            "You're within ${distance.toStringAsFixed(2)}m. Attendance marked!",
      );
    } catch (e) {
      String err = e.toString();
      String msg = "Something went wrong.";

      if (err.contains("expired")) {
        msg = "This QR Code has expired.";
      } else if (err.contains("GPS")) {
        msg = "Failed to get location.";
      } else if (err.contains("already signed")) {
        msg = err;
      } else if (err.contains("not found") || err.contains("closer")) {
        msg = err;
      }

      ScanDialog.showResult(success: false, message: msg);
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        isQRCodeScanned.value = false;
      });
    }
  }

  Future<void> pickImageFromGallery() async {
    if (isImagePickerActive.value) return;

    isImagePickerActive.value = true;

    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final capture = await scannerController.analyzeImage(image.path);
        if (capture != null && capture.barcodes.isNotEmpty) {
          handleQRScan(capture);
        } else {
          ScanDialog.showResult(success: false, message: "No QR code found.");
        }
      }
    } catch (_) {
      ScanDialog.showResult(
        success: false,
        message: "Failed to process image.",
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
