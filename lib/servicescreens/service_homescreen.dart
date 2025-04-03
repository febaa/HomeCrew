import 'package:flutter/material.dart';
import 'package:homecrew/servicescreens/showBookings.dart';

class ServiceHomescreen extends StatefulWidget {
  const ServiceHomescreen({super.key});

  @override
  State<ServiceHomescreen> createState() => _ServiceHomescreenState();
}

class _ServiceHomescreenState extends State<ServiceHomescreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: AppBar(
            backgroundColor: const Color(0xFF006A4E),
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Hello, Service Provider',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Mumbai, 400001',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'What service are you looking for?',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {},
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCard(Icons.assignment, "Service Requests",
                  [Color(0xFF006A4E), Color(0xFF006A4E)], () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => showBookings()
                  ),
                );
              }),
              const SizedBox(height: 20),
              _buildCard(Icons.list, "Your Services Summary",
                  [Color(0xFF006A4E), Color(0xFF006A4E)], () {
                //   Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ShowServiceSummary(serviceProviderId: 'YOUR_PROVIDER_ID_HERE'), // Pass service provider ID
                //   ),
                // );
              }),
              const SizedBox(height: 30),

              // 🔹 Service Provider Guidelines Card
              _guidelinesCard(),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 Guidelines Card with Green Background and White Text
  Widget _guidelinesCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: Color(0xFF006A4E), // Green background
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  "Service Provider Guidelines",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.white), // White Divider
            const SizedBox(height: 8),
            _bulletPoint(
                "Always complete your tasks with professionalism and integrity."),
            _bulletPoint(
                "Ensure timely arrival and communication with clients."),
            _bulletPoint(
                "Maintain proper hygiene and wear appropriate work attire."),
            _bulletPoint(
                "Respect customer privacy and handle sensitive data carefully."),
            _bulletPoint(
                "Report any issues or disputes through the official support channel."),
            const SizedBox(height: 10),
            Text(
              "Failure to follow these guidelines may lead to penalties or account suspension.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 Bullet Point Text (White Color)
  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 🏷️ Reusable Gradient Card
  Widget _buildCard(IconData icon, String title, List<Color> gradientColors,
      void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
