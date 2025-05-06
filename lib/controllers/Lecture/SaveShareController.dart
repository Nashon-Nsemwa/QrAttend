import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart'; // Use image_gallery_saver_plus
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SaveShareController extends GetxController {
  final ScreenshotController screenshotController = ScreenshotController();

  // Check permissions before saving QR code to the gallery
  Future<bool> _checkAndRequestPermissions() async {
    // Check if it's an Android device
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Check the SDK version for Android
      if (androidInfo.version.sdkInt <= 32) {
        // Android 11 and below
        final status = await Permission.storage.request();
        if (status.isGranted) {
          return true; // Permission granted
        } else {
          // Show an error message if permissions are denied
          Get.snackbar(
            "Permission Denied",
            "You need to grant storage permission to save the QR code.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false; // Permission denied
        }
      } else {
        // Android 12 and above
        final status = await Permission.photos.request();
        if (status.isGranted) {
          return true; // Permission granted
        } else {
          // Show an error message if permissions are denied
          Get.snackbar(
            "Permission Denied",
            "You need to grant photo permission to save the QR code.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false; // Permission denied
        }
      }
    }

    // If not Android, return true
    return true;
  }

  /// Save QR Code to Gallery
  Future<void> saveQRCode() async {
    final hasPermission = await _checkAndRequestPermissions();
    if (!hasPermission) return; // Exit if no permission

    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        final result = await ImageGallerySaverPlus.saveImage(
          image,
          quality: 100,
        ); // Use image_gallery_saver_plus
        if (result != null && result['isSuccess']) {
          Get.snackbar(
            "Success",
            "QR Code saved to Gallery!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Error",
            "Failed to save QR Code",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Share QR Code (Without Saving)
  Future<void> shareQRCode() async {
    final hasPermission = await _checkAndRequestPermissions();
    if (!hasPermission) return; // Exit if no permission

    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        // Get the temporary directory to save the screenshot
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/qr_code.png';

        // Create a file in the temporary directory
        final file = File(imagePath);

        // Write the captured image bytes to the file
        await file.writeAsBytes(image);

        // Share the image without saving permanently
        await Share.shareXFiles([
          XFile(file.path),
        ], text: "Here is my QR Code.");

        // Optionally delete the file after sharing if you don't need it anymore
        await file.delete();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to share QR Code",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
