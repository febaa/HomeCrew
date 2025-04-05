import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/consts/rounded_textfield.dart';

final _formKey2 = GlobalKey<FormState>();

class CustomerCreateAccount extends StatefulWidget {
  const CustomerCreateAccount({super.key});

  @override
  State<CustomerCreateAccount> createState() => _CustomerCreateAccountState();
}

class _CustomerCreateAccountState extends State<CustomerCreateAccount> {
  //get auth service
  final authService = AuthService();
  final supabase = Supabase.instance.client;
  //text controllers
  var nameController = TextEditingController();
  var mobController = TextEditingController();
  var emailController = TextEditingController();
  var ageController = TextEditingController();
  var genderController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordRetypeController = TextEditingController();
  String? selectedGender;
  bool _isLoading = false;
  

  //sign up button pressed
  void signUp() async {
    //prepare data
    final name = nameController.text;
    final mobileNo = mobController.text;
    final email = emailController.text;
    final age = ageController.text;
    final gender = selectedGender;
    final password = passwordController.text;
    final confirmPassword = passwordRetypeController.text;

    // check that passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }

    //attempt sign up..
    try {
      await authService.signUpWithEmailPassword(email, password);
      var uid = AuthService().getCurrentUserId();
      print(uid);
      await supabase.from('users').insert({
        'uid': uid,
        'name': name,
        'password': password,
        'email': email,
        'mobile': mobileNo,
        'role': "Customer",
        'age': age,
        'gender': gender
      });

      await supabase.from('wallet').insert({
        'user_id': uid,        
      });

      await supabase.from('coupons').insert({
        'name': "First Order",
        'promocode': "GET21",
        'detail': "Get ₹21 Off on your First Order",
        'validity': DateTime.now().add(Duration(days: 7)), // valid for 7 days from now
        'user_id': uid,
      });

      //pop this register page
      Navigator.pop(context);
    }

    //catch any errors
    catch (e) {
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
          Center(
            child: SizedBox(
              height: 100,
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
            color: const Color(0xFF006A4E),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 80, 16, 0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey2,
                child: Column(
                  children: [
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                    RoundedTextField(
                      label: 'Age',
                      textColor: const Color(0xFF006A4E),
                      controller: ageController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _buildGenderDropdown(),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      label: 'Password',
                      textColor: const Color(0xFF006A4E),
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      //validator: validatePassword,
                      //isObscure: _isSecurePassword,
                      //suffixIcon: togglePassword(),
                    ),
                    const SizedBox(height: 20),
                    RoundedTextField(
                      label: 'Confirm Password',
                      textColor: const Color(0xFF006A4E),
                      controller: passwordRetypeController,
                      keyboardType: TextInputType.text,
                      //validator: ,
                      //isObscure: _isSecurePassword,
                      //suffixIcon: togglePassword(),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        ElevatedButton(
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFF006A4E),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text('Confirm'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: 'Gender',
      labelStyle: const TextStyle(color: Color(0xFF006A4E)),
      filled: true, // Enable filling
      fillColor: Colors.white, // Set white background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF006A4E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF006A4E), width: 2),
      ),
    ),
    value: selectedGender,
    items: ['Male', 'Female']
        .map((gender) => DropdownMenuItem(
              value: gender,
              child: Text(gender),
            ))
        .toList(),
    onChanged: (value) {
      setState(() {
        selectedGender = value!;
      });
    },
    dropdownColor: Colors.white,
    icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
