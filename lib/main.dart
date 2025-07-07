import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:qrattend/bindings/LectureBindings.dart';
import 'package:qrattend/bindings/SharedBindings.dart';
import 'package:qrattend/bindings/StudentBindings.dart';
import 'package:qrattend/config/theme.dart';

import 'package:qrattend/controllers/Shared/UserSessionController.dart';
import 'package:qrattend/controllers/Shared/ThemeController.dart'; //
import 'package:qrattend/firebase_options.dart';
import 'package:qrattend/views/shared/PrivacyPolicy.dart';
import 'package:qrattend/views/shared/TermsConidtion.dart';

// Shared Views
import 'package:qrattend/views/shared/Welcome.dart';
import 'package:qrattend/views/shared/Role.dart';
import 'package:qrattend/views/shared/Settings.dart';
import 'package:qrattend/views/shared/attendance.dart';
import 'package:qrattend/views/shared/Notifications.dart';
import 'package:qrattend/views/shared/About.dart';

// Student Views
import 'package:qrattend/views/students/Dashboard.dart';
import 'package:qrattend/views/students/Module.dart';
import 'package:qrattend/views/students/Navigation.dart';
import 'package:qrattend/views/students/Profile.dart';
import 'package:qrattend/views/students/Scanqr.dart';
import 'package:qrattend/views/students/Schedule.dart';
import 'package:qrattend/views/students/SignHistory.dart';
import 'package:qrattend/views/students/SigninStudent.dart';
import 'package:qrattend/views/students/SignupStudent.dart';

// Lecture Views
import 'package:qrattend/views/lecturers/Dashboard.dart';
import 'package:qrattend/views/lecturers/Announcement.dart';
import 'package:qrattend/views/lecturers/GenerateQr.dart';
import 'package:qrattend/views/lecturers/Profile.dart';
import 'package:qrattend/views/lecturers/SigninLecture.dart';
import 'package:qrattend/views/lecturers/SignupLecture.dart';
import 'package:qrattend/views/lecturers/StudentList.dart';
import 'package:qrattend/views/lecturers/attendance.dart';
import 'package:qrattend/views/lecturers/navigation.dart';
import 'package:qrattend/views/lecturers/schedule.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();

  Get.put(UserSessionController());
  Get.put(ThemeController()); // ✅ Inject ThemeController

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>(); // Get theme controller

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        theme: lightmode,
        darkTheme: darkmode, // Optional: customize your dark theme here
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        getPages: [
          // Shared
          GetPage(name: '/', page: () => WelcomePage()),
          GetPage(name: '/Settings', page: () => Settings()),
          GetPage(name: '/Notification', page: () => Notifications()),
          GetPage(name: '/About', page: () => AboutAppPage()),
          GetPage(name: '/PrivacyPolicy', page: () => PrivacyPolicy()),
          GetPage(name: '/TermsConditions', page: () => TermsCondition()),
          GetPage(
            name: '/Role',
            page: () => Role(),
            binding: RoleBinding(),
            transition: Transition.cupertino,
          ),

          // Students
          GetPage(name: '/StudentDashboard', page: () => StudentDashboard()),
          GetPage(name: '/StudentNavigation', page: () => StudentNavigation()),
          GetPage(name: '/Signin_student', page: () => SigninStudent()),
          GetPage(name: '/Signup_student', page: () => SignupStudent()),
          GetPage(name: '/Student_Profile', page: () => ProfileStudent()),
          GetPage(
            name: '/Modules',
            page: () => Modules(),
            binding: ModuleBinding(),
          ),
          GetPage(
            name: '/StudentSchedule',
            page: () => StudentSchedule(),
            binding: StudentScheduleBinding(),
          ),
          GetPage(
            name: '/SignHistory',
            page: () => SignHistory(),
            transition: Transition.cupertino,
            binding: SignHistoryBinding(),
          ),
          GetPage(
            name: '/StudentAttendance',
            page: () => StudentAttendance(),
            binding: StudentAttendanceBinding(),
          ),
          GetPage(
            name: '/Scanqr',
            page: () => Scanqr(),
            binding: ScanqrBinding(),
          ),

          // Lectures
          GetPage(name: '/LectureDashboard', page: () => LectureDashboard()),
          GetPage(name: '/LectureNavigation', page: () => LectureNavigation()),
          GetPage(name: '/Signin_lecture', page: () => SigninLecture()),
          GetPage(name: '/Signup_lecture', page: () => SignupLecture()),
          GetPage(name: '/Lecture_Profile', page: () => ProfileLecture()),
          GetPage(name: '/GenerateQr', page: () => GenerateQr()),
          GetPage(name: '/Announcement', page: () => Announcement()),
          GetPage(
            name: '/StudentList',
            page: () => StudentList(),
            binding: LectureStudentListBinding(),
          ),
          GetPage(
            name: '/LectureAttendance',
            page: () => LectureAttendance(),
            binding: LectureAttendanceBinding(),
          ),
          GetPage(
            name: '/LectureSchedule',
            page: () => LectureSchedule(),
            binding: LectureSheduleBinding(),
          ),
        ],
      ),
    );
  }
}
