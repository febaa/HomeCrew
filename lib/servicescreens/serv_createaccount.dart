import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/consts/rounded_textfield.dart';

final _formKey2 = GlobalKey<FormState>();

class ServCreateAccount extends StatefulWidget {
  const ServCreateAccount({super.key});

  @override
  State<ServCreateAccount> createState() => _ServCreateAccountState();
}

class _ServCreateAccountState extends State<ServCreateAccount> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;

  // Text controllers
  var nameController = TextEditingController();
  var mobController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordRetypeController = TextEditingController();
  bool _isLoading = false;

  // List of service categories
  final List<String> allCategories = [
    "Plumbing",
    "Electrical",
    "Carpentry",
    "Cleaning",
    "Painting",
    "Pest Control"
  ];

  // Selected categories
  List<String> selectedCategories = [];

  // Function to handle sign-up
  void signUp() async {
    final name = nameController.text;
    final mobileNo = mobController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = passwordRetypeController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords don't match")),
      );
      return;
    }

    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one category.")),
      );
      return;
    }

    try {
      await authService.signUpWithEmailPassword(email, password);
      var uid = AuthService().getCurrentUserId();
      print(uid);

      // Insert user data into `users` table
      await supabase.from('users').insert({
        'uid': uid,
        'name': name,
        'password': password,
        'email': email,
        'mobile': mobileNo,
        'role': "Service"
      });

      // Insert selected categories into `sp_skills` table
      await supabase.from('sp_skills').insert({
        'id': uid,
        'categories': selectedCategories, // JSON format
      });

      // Navigate back after registration
      Navigator.pop(context);
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(color: const Color(0xFF006A4E)), // Green background
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 150, 16, 0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey2,
                child: Column(
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      label: 'Name',
                      textColor: const Color(0xFF006A4E),
                      controller: nameController,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      label: 'Mobile Number',
                      textColor: const Color(0xFF006A4E),
                      controller: mobController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      label: 'Email',
                      textColor: const Color(0xFF006A4E),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Category selection dropdown
                    _buildCategoryDropdown(),

                    const SizedBox(height: 20),
                    RoundedTextField(
                      label: 'Password',
                      textColor: const Color(0xFF006A4E),
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      label: 'Confirm Password',
                      textColor: const Color(0xFF006A4E),
                      controller: passwordRetypeController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF006A4E),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown widget with checkboxes
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            title: Text(
              selectedCategories.isEmpty
                  ? "Choose Your Skills"
                  : selectedCategories.join(", "),
              style: const TextStyle(fontSize: 16),
            ),
            children: allCategories.map((category) {
              return CheckboxListTile(
                title: Text(category),
                value: selectedCategories.contains(category),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedCategories.add(category);
                    } else {
                      selectedCategories.remove(category);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

//Rounded text field class
class RoundedTextField extends StatefulWidget {
  final String label;
  final Color textColor;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final bool isObscure;
  final Widget? suffixIcon;

  const RoundedTextField({
    Key? key,
    required this.label,
    required this.textColor,
    required this.controller,
    required this.keyboardType,
    this.validator,
    this.isObscure = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  _RoundedTextFieldState createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<RoundedTextField> {
  bool isValid = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isObscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: (value) {
        setState(() {
          isValid = widget.validator?.call(value) == null;
        });
      },
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelText: widget.label,
        labelStyle: TextStyle(color: widget.textColor),
        suffixIcon: isValid
            ? const Icon(Icons.check, color: Colors.green)
            : widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
