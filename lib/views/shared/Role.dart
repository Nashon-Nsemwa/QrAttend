import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/controllers/Shared/RoleController.dart';
import 'package:qrattend/controllers/Shared/UserSessionController.dart';

class Role extends StatelessWidget {
  final RoleController controller = Get.find();
  final UserSessionController sessionController = Get.find();

  Role({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),

                            // App Logo
                            const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(
                                'assets/icons/logos/appLogo.png',
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Auth Action Text (Sign Up/Sign In)
                            Obx(
                              () => Text(
                                controller.authAction.value ?? '',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Improved Switch Action Button
                            const SizedBox(height: 8),
                            Obx(
                              () => Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      String newAction =
                                          controller.authAction.value ==
                                                  "Sign Up"
                                              ? "Sign In"
                                              : "Sign Up";
                                      controller.setAction(newAction);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.swap_horiz_rounded,
                                            color: Colors.blue[700],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Switch to ${controller.authAction.value == "Sign Up" ? "Sign In" : "Sign Up"}",
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Title
                            const Text(
                              'Select Your Role',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Subtitle
                            const Text(
                              'Please choose how you want to continue',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 40),

                            // Role Selection Buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _roleOption(
                                    icon: Icons.school_outlined,
                                    label: 'Student',
                                    color: Colors.teal,
                                    onTap: () {
                                      sessionController.setRole(
                                        UserRole.student,
                                      ); // 👈 Set role
                                      controller.navigateToRole("student");
                                    },
                                  ),

                                  _roleOption(
                                    icon: Icons.cast_for_education_outlined,
                                    label: 'Lecturer',
                                    color: Colors.indigoAccent,
                                    onTap: () {
                                      sessionController.setRole(
                                        UserRole.lecturer,
                                      ); // 👈 Set role
                                      controller.navigateToRole("lecture");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Footer pushed to the bottom
                        Padding(
                          padding: const EdgeInsets.only(top: 40, bottom: 40),
                          child: Text(
                            'Powered by Nshon.dev',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _roleOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 40),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
