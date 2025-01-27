import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerAccountPage extends StatefulWidget {
  const CustomerAccountPage({super.key});

  @override
  State<CustomerAccountPage> createState() => _CustomerAccountPageState();
}

class _CustomerAccountPageState extends State<CustomerAccountPage> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;
  late String uid;
  String name = "";

  @override
  void initState() {
    super.initState();
    uid = authService.getCurrentUserId()!; // Get current user ID
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final response = await supabase
          .from('users') // Replace 'users' with your table name
          .select('name') // Select the desired columns
          .eq('uid', uid) // Filter by UID
          .single(); // Fetch a single row

      if (response != null) {
        setState(() {
          name = response['name'] ?? 'No Name';
        });
      } else {
        setState(() {
          name = "Not Found";
        });
      }
    } catch (error) {
      setState(() {
        name = "Error";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF006A4E),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "097986",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              //Add your funcvtionality here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // First Button
                GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 2, 65, 4),
                        ),
                        child: Icon(Icons.book, size: 24, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "My bookings",
                        style: TextStyle(
                            color: Color.fromARGB(255, 2, 65, 4), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Second Button
                GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 2, 65, 4),
                        ),
                        child:
                            Icon(Icons.devices, size: 24, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Native devices",
                        style: TextStyle(
                            color: Color.fromARGB(255, 2, 65, 4), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Third Button
                GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 2, 65, 4),
                        ),
                        child: Icon(Icons.support_agent,
                            size: 24, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Help & Support",
                        style: TextStyle(
                            color: Color.fromARGB(255, 2, 65, 4), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),

          //List Items
          ListTile(
            leading: Icon(Icons.subscriptions_outlined),
            title: Text("My Plans"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.card_membership_outlined),
            title: Text("Plus membership"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.stars_outlined),
            title: Text("My rating"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text("Manage addresses"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.payment_outlined),
            title: Text("Manage payment methods"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text("Settings"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About UC"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            onTap: () {
              try {
                authService.signOut();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
            title: Text(
              "Log Out",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ]),
      ),
    );
  }
}
