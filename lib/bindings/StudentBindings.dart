import 'package:get/get.dart';
import 'package:qrattend/controllers/Student/Module.dart';
import 'package:qrattend/controllers/Student/NavigationControler.dart';
import 'package:qrattend/controllers/Student/ScanqrControler.dart';
import 'package:qrattend/controllers/Student/Schedule.dart';
import 'package:qrattend/controllers/Student/SignHistory.dart';

class StudentNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StudentnavController>(StudentnavController());
  }
}

class ModuleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModuleController>(() => ModuleController());
  }
}

class StudentScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleController>(() => ScheduleController());
  }
}

class ScanqrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QRScanController>(() => QRScanController());
  }
}

class SignHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignHistoryController>(() => SignHistoryController());
  }
}
