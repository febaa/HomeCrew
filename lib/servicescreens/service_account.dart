import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';

class ServiceMyAccount extends StatefulWidget {
  const ServiceMyAccount({super.key});

  @override
  State<ServiceMyAccount> createState() => _ServiceMyAccountState();
}

class _ServiceMyAccountState extends State<ServiceMyAccount> {

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Account")),
      body: Center(
        child: Column(
          children: [
            Text("SERVICE - MY ACCOUNT PAGE"),
            ListTile(
            onTap: () {
              try {
                authService.signOut();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
            title: Text(
              "Log Out",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ],
        ),
      ),
    );
  }
}