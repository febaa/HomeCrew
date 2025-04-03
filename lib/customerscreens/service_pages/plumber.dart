import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customerscreens/cart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlumberWorks extends StatefulWidget {
  const PlumberWorks({super.key});

  @override
  State<PlumberWorks> createState() => _PlumberWorksState();
}

class _PlumberWorksState extends State<PlumberWorks> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;
  List<dynamic> services = [];
  bool isLoading = true;
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = authService.getCurrentUserId()!; // Get current user ID
    fetchServices();
  }

  Future<void> fetchServices() async {
    final response =
        await supabase.from('services').select().eq('category', 'Plumbing');
    setState(() {
      services = response;
      isLoading = false;
    });
  }

  // Function to add service to cart
Future<void> addToCart(BuildContext context, int serviceId) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser; // Get logged-in user
  if (user == null) {
    print("User not logged in");
    return;
  }

  try {
    // Check if service is already in the cart
    final existingItem = await supabase
        .from('cart')
        .select()
        .eq('userId', uid)
        .eq('serviceId', serviceId)
        .maybeSingle();

    if (existingItem != null) {
      // If the service is already in the cart, update the quantity
      await supabase
          .from('cart')
          .update({'quantity': existingItem['quantity'] + 1})
          .eq('id', existingItem['id']);
    } else {
      // If the service is not in the cart, insert a new entry
      await supabase.from('cart').insert({
        'userId': uid,
        'serviceId': serviceId,
        'quantity': 1,
      });
    }

    //Show Snackbar  after successful addition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Service added to cart"),
        backgroundColor: const Color(0xFF006A4E),
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: "View Cart",
          textColor: Colors.white, 
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Cart()));
          },
        ),
      ),
      
    );

    print("Service added to cart successfully!");
  } catch (error) {
    print("Error adding to cart: $error");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF006A4E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/Plumber.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                    child: Container(
                  alignment: Alignment.bottomCenter,
                  color: Colors.black
                      .withOpacity(0.3), // Optional: adds a dark overlay
                  child: Text(
                    "Get your plumbing work done in minutes",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 0, left: 10, right: 10),
              child: services.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator()) // Loading indicator
                  : Column(
                      children: services.map((service) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Service Name and Bookings
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service[
                                            'name'], // Dynamically display name
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.black, size: 20),
                                          const SizedBox(width: 5),
                                          Text(
                                            "(${service['bookings']} bookings)", // Dynamically display bookings
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Pricing Section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₹${service['dprice']}", // Display discounted price
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "₹${service['price']}", // Display original price
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),

                                // Add Button
                                ElevatedButton(
                                  onPressed: () async {
                                    await addToCart(context, service['id']); // Call function to add to cart
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Color(0xFF006A4E)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                  child: const Text(
                                    "Book",
                                    style: TextStyle(color: Color(0xFF006A4E)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 10),
            // Discount Section
            // Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Chip(
            //               label: Text("Save 10% on every order"),
            //               avatar: Icon(Icons.discount, color: Colors.purple),
            //             ),
            //             Chip(
            //               label: Text("Assured reward from online payment"),
            //               avatar: Icon(Icons.credit_card, color: Colors.green),
            //             ),
            //           ],
            //         ),
          ],
        ),
      ),
    );
  }
}
