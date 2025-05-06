import 'package:flutter/material.dart';
import 'package:about/about.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AboutPage(
      values: {'version': '1.0.0', 'year': DateTime.now().year.toString()},
      title: const Text('About QrAttend'),
      applicationVersion: 'Version {{ version }}',
      applicationIcon: const CircleAvatar(
        radius: 40,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image(
            image: AssetImage('assets/icons/logos/appLogo.png'),
            fit: BoxFit.cover,
            height: 80,
            width: 80,
          ),
        ),
      ),

      applicationLegalese: '© {{ year }} QrAttend Inc.',
      applicationDescription: const Text(
        'QrAttend is a smart attendance management system designed for universities. '
        'Leveraging QR code technology, it simplifies and secures student check-ins during lectures. '
        'Lecturers can dynamically generate QR codes for their sessions, while students scan them to register attendance. '
        'The app offers real-time attendance tracking, schedule and module viewing, and personalized notifications for both students and lecturers.\n\n'
        'To enhance accuracy, QrAttend incorporates geolocation to verify physical proximity, preventing fraudulent check-ins. '
        'Lecturers can monitor attendance statistics, print reports, and send announcements. '
        'Students can track their attendance percentage and stay informed through live updates.\n\n'
        'With QrAttend, attendance is automated, secure, and efficient — redefining classroom presence in the digital age.',
      ),

      children: const <Widget>[
        ListTile(
          leading: Icon(Icons.email),
          title: Text('Contact Us'),
          subtitle: Text('nashonnsemwa@gmail.com'),
        ),
        ListTile(leading: Icon(Icons.link), title: Text('GitHub Account')),
      ],
    );
  }
}
