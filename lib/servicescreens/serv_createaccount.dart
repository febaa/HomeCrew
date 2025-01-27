import 'package:flutter/material.dart';
import '/consts/rounded_textfield.dart';

final _formKey2 = GlobalKey<FormState>();

class ServCreateAccount extends StatefulWidget {
  const ServCreateAccount({super.key});

  @override
  State<ServCreateAccount> createState() => _ServCreateAccountState();
}

class _ServCreateAccountState extends State<ServCreateAccount> {
  //text controllers
  var nameController = TextEditingController();
  var mobController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordRetypeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            color:const Color(0xFF006A4E), // Green color
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 150, 16, 0),
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
                          onPressed: () {},
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
