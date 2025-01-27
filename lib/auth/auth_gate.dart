// Auth gate will continously listen for auth state changes.




import 'package:flutter/material.dart';
import 'package:homecrew/customer_or_service.dart';
import 'package:homecrew/customerscreens/customerNavbar.dart';
import 'package:homecrew/customerscreens/customer_homescreen.dart';
import 'package:homecrew/customerscreens/customer_signin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      //Build appropriate page based on auth state 
      builder: (context, snapshot) {
        //loading..
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        //check if there is a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const CustomerNavbar(0);
        }
        else {
          return CustomerOrService();
        }
      }
    );
  }
}
