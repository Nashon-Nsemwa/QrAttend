import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
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

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String lecturerUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchCourseModulePairs();
    fetchDurations();
    loadQRsFromStorage();
    startCountdown();

    _getCurrentLocation()
        .then((pos) {
          fetchedPosition.value = pos;
        })
        .catchError((e) {
          debugPrint("Initial location fetch failed: $e");
        });
  }

  // Fetch courses/modules from Firestore where lecturer == "Mr Nsemwa"
  Future<void> fetchCourseModulePairs() async {
    Map<String, List<String>> courseModules = {};

    QuerySnapshot coursesSnapshot = await firestore.collection('courses').get();
    for (var courseDoc in coursesSnapshot.docs) {
      var modulesSnapshot =
          await firestore
              .collection('courses')
              .doc(courseDoc.id)
              .collection('modules')
              .where('lecturerUid', isEqualTo: lecturerUid)
              .get();

      if (modulesSnapshot.docs.isNotEmpty) {
        courseModules[courseDoc['name']] =
            modulesSnapshot.docs
                .map((moduleDoc) => moduleDoc['name'].toString())
                .toList();
      }
    }

    coursesWithModules.value = courseModules;
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
      // 🧭 Get Location
      Position position = fetchedPosition.value ?? await _getCurrentLocation();
      fetchedPosition.value = position;

      // 📄 Setup metadata
      String course = selectedCourse.value;
      String module = selectedModule.value;
      String todayStr = getFormattedDate().replaceAll('-', '');
      String attendanceDocId = "att_$todayStr";
      DateTime now = DateTime.now();

      int minutes = int.parse(selectedDuration.value.split(" ")[0]);
      DateTime newExpirationTime = now.add(Duration(minutes: minutes));
      String secrecyCode = "secret_${now.millisecondsSinceEpoch}";

      // 🔎 Find Course + Module
      final courseSnap =
          await firestore
              .collection('courses')
              .where('name', isEqualTo: course)
              .get();
      if (courseSnap.docs.isEmpty) throw Exception("Course not found");

      final courseDoc = courseSnap.docs.first;
      final courseDocId = courseDoc.id;

      final moduleSnap =
          await firestore
              .collection('courses')
              .doc(courseDocId)
              .collection('modules')
              .where('name', isEqualTo: module)
              .where('lecturerUid', isEqualTo: lecturerUid)
              .get();
      if (moduleSnap.docs.isEmpty) throw Exception("Module not found");

      final moduleDoc = moduleSnap.docs.first;
      final moduleDocId = moduleDoc.id;

      // 🔍 Fetch lecturer name
      final lecSnap =
          await firestore.collection('lectures').doc(lecturerUid).get();
      final lecName = lecSnap.data()?['name'] ?? 'Unknown';

      // 🧠 Build QR model
      final qrCode = QRCode(
        lectureId: "Lec_${now.millisecondsSinceEpoch}",
        course: course,
        module: module,
        dateCreated: now.toString(),
        expirationTime: newExpirationTime,
        secrecyCode: secrecyCode,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      saveQRCodeToStorage(qrCode);
      expirationTime.value = newExpirationTime;
      generatedText.value = jsonEncode(qrCode.toMap());

      // 🔥 Attendance document reference (one per day)
      final attendanceRef = firestore
          .collection('courses')
          .doc(courseDocId)
          .collection('modules')
          .doc(moduleDocId)
          .collection('attendance')
          .doc(attendanceDocId);

      // ✅ Only create attendance doc if not exists
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(attendanceRef);

        if (!snapshot.exists) {
          transaction.set(attendanceRef, {
            'createdOn': Timestamp.now(),
            'createdBy': lecName,
            'students': {}, // will be filled later by students
          });
        } else {
          debugPrint("✅ Attendance already exists for today.");
        }
      });

      startCountdown();
    } catch (e) {
      Get.snackbar(
        "Error",
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
    // Returns YYYY-MM-DD
    return DateTime.now().toLocal().toString().split(' ')[0];
  }

  List<String> getModulesForSelectedCourse() {
    return coursesWithModules[selectedCourse.value] ?? [];
  }
}
