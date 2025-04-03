import 'package:flutter/material.dart';
import 'package:homecrew/customerscreens/customer_get_started.dart';
import 'package:homecrew/servicescreens/serv_get_started.dart';
import 'package:homecrew/splash_screen.dart';

class CustomerOrService extends StatelessWidget {
  const CustomerOrService({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: (Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Are you a",
                style: TextStyle(fontSize: 22, color: Color(0xFF006A4E))
              ),
              SizedBox(
                height: 10,
              ),
              CustomButton(
                imageAsset: 'assets/images/customer.png',
                buttonText: 'Customer',
                onPressed: () {
                  _navigateToSignInScreen(context, CustomerGetStarted(), false);
                },
                
              ),
              const Divider(
                color: const Color(0xFF006A4E), // Line color
                thickness: 1, // Line thickness
                indent: 70, // Left spacing
                endIndent: 70, // Right spacing
              ),
              CustomButton(
                imageAsset: 'assets/images/service.png',
                buttonText: 'Service Provider',
                onPressed: () {
                  _navigateToSignInScreen(context, ServiceproviderGetStarted(), false);
                },
              ),
            ],
          )),
        ),
      ),
    );
  }
}
void _navigateToSignInScreen(
      BuildContext context, Widget signInScreen, bool isSeller) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => signInScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (isSeller) {
            // For Seller, use SlideTransition to slide from the top
            return SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                        .animate(animation),
                child: child);
          } else {
            // For Customer, use SlideTransition to slide from the bottom
            return SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                        .animate(animation),
                child: child);
          }
        },
      ),
    );
  }

class CustomButton extends StatelessWidget {
  final String imageAsset;
  final String buttonText;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.imageAsset,
    required this.buttonText,
    required this.onPressed,
  }) ;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        height: 230,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006A4E).withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                image: DecorationImage(
                  image: AssetImage(imageAsset),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              height: 80,
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10)),
                color: const Color(0xFF006A4E),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
     ),
);
}
}