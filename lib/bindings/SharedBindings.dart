import 'package:get/get.dart';
import 'package:qrattend/controllers/Shared/NotificationController%20.dart';
import 'package:qrattend/controllers/Shared/RoleController.dart';

import 'package:qrattend/controllers/Shared/StudentAttendance.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}

class StudentAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceController>(() => AttendanceController());
  }
}

class RoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleController>(() => RoleController());
  }
}
