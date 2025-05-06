import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
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

  /// Toggles flashlight on/off
  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
    scannerController.toggleTorch();
  }

  /// Switches between front and back camera
  void switchCamera() {
    scannerController.switchCamera();
  }

  /// Handles QR code scanning from live camera
  void handleQRScan(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      String? scannedCode = barcodes.first.rawValue;

      if (!isQRCodeScanned.value) {
        isQRCodeScanned.value = true;

        try {
          if (scannedCode == null) {
            throw Exception("QR Code content is empty.");
          }

          final qrData = jsonDecode(scannedCode);
          final double qrLatitude = qrData['latitude'];
          final double qrLongitude = qrData['longitude'];

          ScanDialog.showLoading();

          final position = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                "Unable to get location. Please check your GPS settings.",
              );
            },
          );

          double distanceInMeters = Geolocator.distanceBetween(
            qrLatitude,
            qrLongitude,
            position.latitude,
            position.longitude,
          );

          if (distanceInMeters <= 100) {
            ScanDialog.showResult(
              success: true,
              message:
                  "You're within ${distanceInMeters.toStringAsFixed(2)} meters. Attendance marked!",
            );
            // TODO: Add your logic here to mark attendance or navigate to another page
          } else {
            ScanDialog.showResult(
              success: false,
              message:
                  "You're ${distanceInMeters.toStringAsFixed(2)} meters away. Please move closer to the QR point.",
            );
          }
        } catch (e) {
          String friendlyMessage =
              "Invalid QR Code. Please try a valid QR Code.";

          if (e.toString().contains("FormatException")) {
            friendlyMessage =
                "Invalid QR Code format. Please try a valid QR Code.";
          } else if (e.toString().contains("location") ||
              e.toString().contains("GPS")) {
            friendlyMessage =
                "Failed to get location. Please ensure GPS is enabled.";
          } else if (e.toString().contains("empty")) {
            friendlyMessage = "The scanned QR code doesn't contain valid data.";
          }

          ScanDialog.showResult(success: false, message: friendlyMessage);
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

  /// Optional: Pick image from gallery and scan QR from it
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
          handleQRScan(capture!); // Reusing main logic
          // TODO: Add logic here to process the QR code and handle the backend processing
          // For example, you can send the scanned QR data to the backend to log attendance
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
        message:
            "Failed to process image. Please try again or choose another image.",
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
