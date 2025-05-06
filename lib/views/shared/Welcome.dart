import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattend/controllers/Shared/WelcomeController.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});
  final WelcomeController controller = Get.put(WelcomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with better shadow and elevation
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icons/logos/appLogo.png',
                      fit: BoxFit.contain,
                      scale: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // App Name with better typography
                Text(
                  "QrAttend",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 40),

                // Welcome Text with gradient
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[700]!],
                      ).createShader(bounds),
                  child: Text(
                    "Welcome!",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Color is overridden by gradient
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Description Text with improved readability
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Make attendance easy and stress-free with QrAttend - Quick, Secure, and Real-time tracking at your fingertips.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Buttons Section
                Column(
                  children: [
                    // Sign In Button with improved visual weight
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => controller.handleAuthMode("Sign In"),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.blue[600]!,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Create Account Button with subtle gradient
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.blue[600]!, Colors.blue[400]!],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => controller.handleAuthMode("Sign Up"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
