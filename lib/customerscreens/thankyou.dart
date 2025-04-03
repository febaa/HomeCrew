import 'package:flutter/material.dart';
import 'package:homecrew/customerscreens/customerNavbar.dart';

class ThankYouPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50], // Light background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated check icon
              AnimatedContainer(
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.check_circle,
                  size: 120,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: 30),
              
              // Thank you message
              Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 10),

              // Sub-message
              Text(
                'We’ve received your service request and appreciate you reaching out to us.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Update message
              Text(
                'You’ll be notified once a service provider accepts or negotiates your request. We’re here to help you!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Go back button with stylish design
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => CustomerNavbar(0)));
                },
                child: Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                 backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  shadowColor: Colors.green[400],
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
