import 'package:get/get.dart';
import 'package:qrattend/models/Module.dart';

class ModuleController extends GetxController {
  // Reactive list of modules
  var moduleList = <ModuleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchModules();
  }

  // Fetch module data (hardcoded or from API)
  void fetchModules() {
    // Hardcoded example modules
    var modules = [
      ModuleModel(
        name: "Cryptography",
        code: "CS101",
        description: "An introduction to Cryptography concepts.",
        lecturer: "Dr. John",
      ),
      ModuleModel(
        name: "Data Structures",
        code: "CS102",
        description: "Learn about various data structures.",
        lecturer: "Prof. Sarah",
      ),

      // Add more modules here
    ];

    moduleList.assignAll(modules);
  }
}
