import 'package:flutter/material.dart';
import 'package:homecrew/customer_or_service.dart';
import 'package:homecrew/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // supabase setup
  await Supabase.initialize(
    url: "https://zvfblsevxkbralqcodox.supabase.co", 
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2ZmJsc2V2eGticmFscWNvZG94Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY3ODU0MjEsImV4cCI6MjA1MjM2MTQyMX0.QlYyeF9_OxctTKJbJFEqN9V3yKYnOyrLfg_UM6AV7e4",
  );
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}