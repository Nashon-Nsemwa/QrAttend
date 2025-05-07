import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/controllers/Shared/ThemeController.dart';
import 'package:qrattend/controllers/Shared/UserSessionController.dart';

class Settings extends StatelessWidget {
  Settings({super.key});
  final UserSessionController sessionController =
      Get.find<UserSessionController>();
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              // Account Category inside a white container
              Container(
                decoration: BoxDecoration(
                  color: theme.onSecondary,
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Adjust the radius as needed
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildListTile(
                      icon: Icons.person,
                      title: "Profile",
                      onTap: () {
                        // Handle Profile action
                        final role = sessionController.role.value;
                        if (role == UserRole.student) {
                          Get.toNamed("/Student_Profile");
                        } else if (role == UserRole.lecturer) {
                          Get.toNamed("/Lecture_Profile");
                        }
                      },
                      context: context,
                    ),
                    _buildListTile(
                      icon: Icons.logout_rounded,
                      title: "Sign Out",
                      onTap: () {
                        // Handle Lo action
                        Get.defaultDialog(
                          title: "Sign Out",
                          middleText: "Are you sure you want to sign out?",
                          textCancel: "Cancel",
                          textConfirm: "Sign Out",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.redAccent,
                          onConfirm: () {
                            sessionController
                                .clearSession(); // Clears session or token
                            Get.offAllNamed(
                              "/",
                            ); // Redirect to login or welcome
                          },
                        );
                      },
                      context: context,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              const Text(
                "General",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              // General Category inside a white container
              Container(
                decoration: BoxDecoration(
                  color: theme.onSecondary,
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Adjust the radius as needed
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildListTile(
                      icon: Icons.nightlight_round,
                      title: "Theme",
                      trailing: Obx(
                        () => Switch(
                          activeColor: theme.onPrimary,
                          value: themeController.isDarkMode.value,
                          onChanged: (value) {
                            themeController.toggleTheme();
                          },
                        ),
                      ),
                      onTap:
                          () {}, // No need for tap if you're using the toggle
                      context: context,
                    ),
                    _buildListTile(
                      icon: Icons.star_border,
                      title: "Rate us",
                      onTap: () {
                        // Handle Rate us action
                      },
                      context: context,
                    ),
                    _buildListTile(
                      icon: Icons.info_outline,
                      title: "About",
                      onTap: () {
                        // Handle About action
                        Get.toNamed("/About");
                      },
                      context: context,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Privacy & Account Terms",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Privacy & Account Terms Category inside a white container
              Container(
                decoration: BoxDecoration(
                  color: theme.onSecondary,
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Adjust the radius as needed
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildListTile(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      onTap: () {
                        // Handle Privacy Policy action
                        Get.toNamed("/PrivacyPolicy");
                      },
                      context: context,
                    ),
                    _buildListTile(
                      icon: Icons.document_scanner_outlined,
                      title: "Terms & Conditions",
                      onTap: () {
                        // Handle Terms & Conditions action
                        Get.toNamed("/TermsConditions");
                      },
                      context: context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    required BuildContext context, // Add BuildContext parameter
  }) {
    final theme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: theme.onPrimary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: theme.onPrimary,
        ),
      ),
      trailing:
          trailing ??
          Icon(Icons.arrow_forward_ios, size: 16, color: theme.onPrimary),
      onTap: onTap,
    );
  }
}
