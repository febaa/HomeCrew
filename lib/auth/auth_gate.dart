import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customer_or_service.dart';
import 'package:homecrew/customerscreens/customerNavbar.dart';
import 'package:homecrew/servicescreens/serviceNavbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate(this.direct, {this.login, super.key});

  final bool direct;
  final String? login; // Login is optional for direct = true

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final authService = AuthService(); // Create authService instance
  String? uid; // Store user ID
  String? userRole; // Store user role
  bool isLoading = true; // Flag for initial loading
  bool isCheckingRole = true; // Flag for role verification
  String? errorMessage; // Store error message

  @override
  void initState() {
    super.initState();
    getUserData(); // Fetch user data when the page loads
  }

  // Get user ID and fetch role from Supabase
  Future<void> getUserData() async {
    uid = authService.getCurrentUserId(); // Get current user ID
    if (uid != null) {
      // Fetch user role from Supabase
      final response = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('uid', uid!)
          .single();

      if (response != null && response['role'] != null) {
        setState(() {
          userRole = response['role']; // Set the user role
          isCheckingRole = false; // Mark role verification complete
          isLoading = false; // Mark loading complete
        });
      } else {
        setState(() {
          isCheckingRole = false;
          isLoading = false; // Stop loading if no role found
        });
      }
    } else {
      setState(() {
        isCheckingRole = false;
        isLoading = false; // Stop loading if no uid
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      // Build appropriate page based on auth state
      builder: (context, snapshot) {
        // Show loading indicator while checking role or waiting for auth
        if (isLoading || isCheckingRole || snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if there is a valid session
        final session = snapshot.hasData ? snapshot.data!.session : null;

        // Prevent UI change until role verification is complete
        if (session != null && userRole != null && !isCheckingRole) {
          // Case 1: If direct is true, show the Navbar based on userRole
          if (widget.direct == true) {
            return _navigateToCorrectNavbar(userRole!);
          }

          // Case 2: If direct is false, compare userRole with login
          if (widget.direct == false && widget.login != null) {
            if (userRole == widget.login) {
              return _navigateToCorrectNavbar(userRole!);
            } else {
              // Role mismatch, log out immediately and show error screen
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await Supabase.instance.client.auth.signOut();
              });
              return _showErrorScreen(errorMessage);
            }
          }
        }

        // Case 3: No valid session or no role found
        if (session == null && widget.direct == true) {
          return CustomerOrService();
        }

        // Case 4: Error handling for no valid session and direct == false
        if (session == null && widget.direct == false && widget.login == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              errorMessage =  "No ${widget.login} Account Found";
            });
          });
          return _showErrorScreen(errorMessage);
        }


        // Default to CustomerOrService if nothing matches
        return CustomerOrService();
      },
    );
  }

  // Show the correct navbar based on the user role
  Widget _navigateToCorrectNavbar(String role) {
    if (role == "Customer") {
      return const CustomerNavbar(0);
    } else if (role == "Service") {
      return const ServiceNavbar(0);
    }
    return CustomerOrService();
  }

  // Show error screen with retry button
  Widget _showErrorScreen(String? errorMessage) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                errorMessage ?? "Something went wrong",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerOrService()),
                  );
                },
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
