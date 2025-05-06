import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrattend/controllers/Student/ScanqrControler.dart';

class Scanqr extends StatelessWidget {
  final QRScanController controller = Get.find();

  Scanqr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // QR Scanner Camera View
          MobileScanner(
            controller: controller.scannerController,
            onDetect:
                (BarcodeCapture capture) => controller.handleQRScan(capture),
          ),

          // Semi-transparent overlay with a blur effect applied to the background
          // 🧨i will come back to i later to imprement the blur feature around the scan area
          /* Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),*/

          // Cancel button at top left
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                // Handle cancel action
                Get.back();
              },
            ),
          ),

          // Change Camera and Torch icons at top right
          Positioned(
            top: 50,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.cameraswitch, color: Colors.white, size: 30),
                  onPressed: controller.switchCamera,
                ),
                SizedBox(width: 20),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      controller.isFlashOn.value
                          ? Icons.flashlight_on_rounded
                          : Icons.flashlight_off_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: controller.toggleFlash,
                  ),
                ),
              ],
            ),
          ),

          // Centered scanning area with custom circular bold edges (above the blur)
          Center(
            child: CustomPaint(
              size: Size(250, 250),
              painter: CircularBorderPainter(),
            ),
          ),

          // Upload from Gallery button at the bottom
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: controller.pickImageFromGallery,
              icon: Icon(Icons.upload, color: Colors.white),
              label: Text(
                'Upload from Gallery',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke;

    // Drawing the thinner border on all sides
    paint.strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(20)),
      paint,
    );

    // Drawing the bold circular corners (top-left, top-right, bottom-left, bottom-right)
    paint.strokeWidth = 6;

    // Top-left corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, 0), radius: 20),
      3.14,
      1.57,
      false,
      paint,
    );

    // Top-right corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width, 0), radius: 20),
      4.71,
      1.57,
      false,
      paint,
    );

    // Bottom-left corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, size.height), radius: 20),
      1.57,
      1.57,
      false,
      paint,
    );

    // Bottom-right corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width, size.height), radius: 20),
      0,
      1.57,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
