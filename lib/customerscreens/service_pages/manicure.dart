import 'package:flutter/material.dart';

class ManicureandPedicure extends StatefulWidget {
  const ManicureandPedicure({super.key});

  @override
  State<ManicureandPedicure> createState() => _ManicureandPedicureState();
}

class _ManicureandPedicureState extends State<ManicureandPedicure> {
  final List<String> _images = [
    'assets/images/manicure&pedicure.png',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF006A4E),
        elevation: 0,
        title: const Text("Manicure & Pedicure", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Background Image
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Image.asset(
                    _images[0],
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only( right: 5.0, bottom: 2.0, ),
              child: Column(
                children: [
                  Text("Select your Service",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 2, 65, 4),
                  ),
                  ),
                            
                  Divider(),

                  ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0), // Adjust height
            leading: Image.asset('assets/images/manicure.png',
            width:40,
            height:40,
            ),
            title: Text("Manicure", style: TextStyle(color: const Color.fromARGB(255, 2, 65, 4), fontWeight: FontWeight.bold),),
            //subtitle: Text("Get your hair cut by professionals"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          Divider(),

          
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0), // Adjust height
            leading: Image.asset('assets/images/pedicure.png',
            width:40,
            height:40,
            ),
            title: Text("Pedicure", style: TextStyle(color: const Color.fromARGB(255, 2, 65, 4), fontWeight: FontWeight.bold),),
            //subtitle: Text("Get your hair colored by professionals"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}