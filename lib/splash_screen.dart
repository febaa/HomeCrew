import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecrew/auth/auth_gate.dart';
import 'package:homecrew/customer_or_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual);
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => AuthGate(true, login: "DIRECT", ),
      ));
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF006A4E),
 // Set background color to green
      body: Center(
        child: Image.asset(
          'assets/images/homecrew_logo.png', // Path to your logo
           // Ensures the logo is displayed in white
          width: MediaQuery.of(context).size.width * 1, // Adjust the size of the logo
          height: MediaQuery.of(context).size.height * 2,
        ),
      ),
    );
  }
}
