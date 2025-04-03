import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_gate.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customerscreens/customer_createaccount.dart';
import 'package:homecrew/customerscreens/customer_homescreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerSignin extends StatefulWidget {
  const CustomerSignin({super.key});

  @override
  State<CustomerSignin> createState() => _CustomerSigninState();
}

class _CustomerSigninState extends State<CustomerSignin> {
  //get auth service
  final authService = AuthService();

  //text controllers
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

  //sign in button pressed
  void signIn() async {
    //prepare data
    final email = emailController.text;
    final password = passwordController.text;

    //attempt login..
    try {
      await authService.signInWithEmailPassword(email, password);
      print("LOGGED IN AS CUSTOMER");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthGate(false, login: "Customer", )));
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
          leading: const BackButton(
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                height: 1000,
                width: double.infinity,
                child: Container(
                  decoration: const BoxDecoration(
                      //image:DecorationImage(
                      // image: image)
                      //fit: BoxFit.cover,
                      ),
                ),
              ),
            ),
            Container(
              color:const Color(0xFF006A4E),
            ),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text(
                            'Customer Log In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RoundedTextField(
                            label: 'Email',
                            textColor: Colors.black,
                            controller: emailController,
                            isObscure: false,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          RoundedTextField(
                            label: 'Password',
                            textColor: Colors.black,
                            controller: passwordController,
                            isObscure: true,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: signIn,
                            style: ElevatedButton.styleFrom(
                              foregroundColor:const Color(0xFF006A4E),
                              backgroundColor: Colors.white,
                            ),
                            child: Text("Sign In"),
                          )
                        ]))))
          ],
        ));
  }
}

class RoundedTextField extends StatelessWidget {
  final String label;
  final Color textColor;
  final TextEditingController controller;
  final bool isObscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const RoundedTextField({
    super.key,
    required this.label,
    required this.textColor,
    required this.controller,
    required this.isObscure,
    required this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
