import 'package:flutter/material.dart';
import 'package:homecrew/servicescreens/serv_createaccount.dart';
import 'package:homecrew/servicescreens/serv_signin.dart';

class ServiceproviderGetStarted extends StatelessWidget {
  const ServiceproviderGetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006A4E),
      body: Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              32, MediaQuery.of(context).size.height / 3.5, 32, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Get\nStarted!',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
//                  const Padding(
//                    padding: EdgeInsets.only(left: 8.0),
              Text('Join us now and start\nyour jouney as a Service Provider',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  )),
                  const SizedBox(height:20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ServCreateAccount()));
                      }, 
                      child: Text("Create a Service Provider Account", style: TextStyle(color: Color(0xFF006A4E),),),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        backgroundColor: Colors.white,
                        
                      ),
                    
                    ),
                  ),
                  const SizedBox(height:5),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ServSignin()));
                      }, 
                      child: Text("Log in to Service Provider Account", style: TextStyle(color:const Color(0xFF006A4E),),),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        backgroundColor: Colors.white,
                        
                      ),
                    
                    ),
                  )

            ],
          ),
        ),
      ),
    );
  }
}
