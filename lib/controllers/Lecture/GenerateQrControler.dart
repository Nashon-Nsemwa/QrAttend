import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qrattend/models/GenerateQrCodeData.dart';

class GenerateQrController extends GetxController {
  final box = GetStorage();

  var generatedQRs = <QRCode>[].obs;
  var selectedCourse = ''.obs;
  var selectedModule = ''.obs;
  var selectedDuration = ''.obs;
  var generatedText = ''.obs;
  var isLoading = false.obs;
  var expirationTime = DateTime.now().obs;
  var remainingTime = "Expired".obs;

  var coursesWithModules = <String, List<String>>{}.obs;
  var durations = RxList<String>([]);

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  Rxn<Position> fetchedPosition = Rxn<Position>();

  @override
  void onInit() {
    super.onInit();
    fetchCourseModulePairs();
    fetchDurations();
    loadQRsFromStorage();
    startCountdown();

    // Fetch location in the background
    _getCurrentLocation()
        .then((pos) {
          fetchedPosition.value = pos;
        })
        .catchError((e) {
          debugPrint("Initial location fetch failed: $e");
        });
  }

  Future<void> fetchCourseModulePairs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    coursesWithModules.value = {
      'Computer Science': ['Database Management', 'Web-based DB', 'Networking'],
      'Information Technology': [
        'Cybersecurity',
        'Cloud Computing',
        'AI Basics',
      ],
      'Software Engineering': [
        'Mobile Development',
        'Backend Systems',
        'Testing Strategies',
      ],
    };
  }

  Future<void> fetchDurations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    durations.value = ['5 min', '10 min', '15 min', '30 min'];
  }

  void loadQRsFromStorage() {
    List stored = box.read('generated_qrs') ?? [];
    generatedQRs.value = stored.map((e) => QRCode.fromMap(e)).toList();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        Get.snackbar(
          "Timeout",
          "Location request timed out. Please ensure GPS is enabled and try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        throw Exception(
          "Location request timed out. Please ensure GPS is enabled and try again.",
        );
      },
    );
  }

  Future<void> generateQRCode() async {
    if (selectedCourse.value.isEmpty ||
        selectedModule.value.isEmpty ||
        selectedDuration.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select course, module, and duration",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      Position position;

      // Check if background location was fetched
      if (fetchedPosition.value == null) {
        // Try fetching again with a timeout
        position = await _getCurrentLocation().timeout(
          Duration(seconds: 10),
          onTimeout: () {
            Get.snackbar(
              "Timeout",
              "Location request timed out. Please ensure GPS is enabled and try again.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            throw Exception("Fetching location timed out.");
          },
        );
        fetchedPosition.value = position; // store it
      } else {
        position = fetchedPosition.value!;
      }

      String lectureId = "Lec_${DateTime.now().millisecondsSinceEpoch}";
      String course = selectedCourse.value;
      String module = selectedModule.value;
      String dateCreated = DateTime.now().toString();

      int minutes = int.parse(selectedDuration.value.split(" ")[0]);
      DateTime newExpirationTime = DateTime.now().add(
        Duration(minutes: minutes),
      );
      String secrecyCode = "secret_${DateTime.now().millisecondsSinceEpoch}";

      QRCode qrCode = QRCode(
        lectureId: lectureId,
        course: course,
        module: module,
        dateCreated: dateCreated,
        expirationTime: newExpirationTime,
        secrecyCode: secrecyCode,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      saveQRCodeToStorage(qrCode);
      expirationTime.value = newExpirationTime;

      generatedText.value = jsonEncode({
        'lectureId': lectureId,
        'course': course,
        'module': module,
        'dateCreated': dateCreated,
        'expirationTime': newExpirationTime.toIso8601String(),
        'secrecyCode': secrecyCode,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      startCountdown();
    } catch (e) {
      Get.snackbar(
        "Location Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void saveQRCodeToStorage(QRCode qrCode) {
    List stored = box.read('generated_qrs') ?? [];
    stored.add(qrCode.toMap());
    box.write('generated_qrs', stored);
    generatedQRs.add(qrCode);
  }

  List<QRCode> getActiveQRs() {
    DateTime now = DateTime.now();
    return generatedQRs.where((qr) => qr.expirationTime.isAfter(now)).toList();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = expirationTime.value.difference(now);

      if (remaining.isNegative) {
        remainingTime.value = "Expired";
        timer.cancel();
      } else {
        remainingTime.value =
            "${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')} remaining";
      }
    });
  }

  bool isModuleActive(String module) {
    return getActiveQRs().any((qr) => qr.module == module);
  }

  void loadSelectedQRCode(QRCode qrCode) {
    generatedText.value = jsonEncode({
      'lectureId': qrCode.lectureId,
      'course': qrCode.course,
      'module': qrCode.module,
      'dateCreated': qrCode.dateCreated,
      'expirationTime': qrCode.expirationTime.toIso8601String(),
      'secrecyCode': qrCode.secrecyCode,
      'latitude': qrCode.latitude,
      'longitude': qrCode.longitude,
    });
    expirationTime.value = qrCode.expirationTime;
    selectedModule.value = qrCode.module;
    selectedCourse.value = qrCode.course;
    startCountdown();
  }

  String getFormattedDate() {
    return DateTime.now().toLocal().toString().split(' ')[0];
  }

  List<String> getModulesForSelectedCourse() {
    return coursesWithModules[selectedCourse.value] ?? [];
  }
}
