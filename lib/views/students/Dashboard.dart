import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart'; // For navigation

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 3 : 2; // Adjust for tablets

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 25),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Hello", style: TextStyle(fontSize: 14)),
                Text(
                  "Nashon Nsemwa",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
          child: Column(
            children: [
              // Responsive Grid Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      List<Map<String, dynamic>> items = [
                        {
                          'icon': 'assets/icons/scan qr.svg',
                          'label': "Scan QR",
                          'route': '/Scanqr',
                        },
                        {
                          'icon': 'assets/icons/schedule.svg',
                          'label': "Schedule",
                          'route': '/StudentSchedule',
                        },
                        {
                          'icon': 'assets/icons/modules3.svg',
                          'label': "Modules",
                          'route': '/Modules',
                        },
                        {
                          'icon': 'assets/icons/sign-history.svg',
                          'label': "Sign History",
                          'route': '/SignHistory',
                        },
                      ];

                      return _dashboardItem(
                        iconPath: items[index]['icon']!,
                        label: items[index]['label']!,
                        onTap: () => Get.toNamed(items[index]['route']),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              // "View Attendance" Card
              Card(
                elevation: 3,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: SvgPicture.asset(
                    'assets/icons/attendance-person.svg',
                    width: 30,
                    height: 30,
                  ),
                  title: Text(
                    "View Attendance",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () => Get.toNamed('/StudentAttendance'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated dashboard item to include tap navigation
  Widget _dashboardItem({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.blue,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 50,
                height: 50,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              SizedBox(height: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
