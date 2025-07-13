import 'package:get/get.dart';
import 'package:flutter/material.dart';

void showAlert(String title, String message, Color color) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: color,
    colorText: Colors.white,
    duration: const Duration(seconds: 2),
    isDismissible: true,
    snackStyle: SnackStyle.FLOATING,
  );
}
