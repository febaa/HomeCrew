import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customerscreens/customerNavbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ServicePage extends StatefulWidget {
  final String category;
  final String subcategory;
  final String imageUrl;

  const ServicePage({
    required this.category,
    required this.subcategory,
    required this.imageUrl,
    super.key,
  });

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  List<Map<String, dynamic>> services = [];
  final supabase = Supabase.instance.client;
  int? selectedIndex;
  bool isLoading = true;
  late String uid;
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    uid = authService.getCurrentUserId()!; // Get current user ID
    fetchServices();
  }

  Future<void> fetchServices() async {
    final response = await supabase
        .from('services')
        .select()
        .eq('category', widget.category)
        .eq('subcategory', widget.subcategory);

    if (mounted) {
      setState(() {
        services = List<Map<String, dynamic>>.from(response);
        isLoading = false;
        if (services.isNotEmpty) {
          selectedIndex = 0;
        }
      });
    }
  }

  // Function to add service to cart
  Future<void> addToCart(BuildContext context, int serviceId) async {
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
            .update({'quantity': existingItem['quantity'] + 1}).eq(
                'id', existingItem['id']);
      } else {
        // If the service is not in the cart, insert a new entry
        await supabase.from('cart').insert({
          'userId': uid,
          'serviceId': serviceId,
          'quantity': 1,
        });
      }

    // Show alert dialog after successfully adding to cart
    showAddToCartDialog(context, services[selectedIndex!]['name']);

      //Show Snackbar  after successful addition
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text("Service added to cart"),
      //     backgroundColor: const Color(0xFF006A4E),
      //     duration: const Duration(days: 1),
      //     action: SnackBarAction(
      //       label: "View Cart",
      //       textColor: Colors.white,
      //       onPressed: () {
      //         Navigator.push(context, MaterialPageRoute(builder: (context) => Cart()));
      //       },
      //     ),
      //   ),

      // );

      print("Service added to cart successfully!");
    } catch (error) {
      print("Error adding to cart: $error");
    }
  }

  // Show alert dialog when service is added
void showAddToCartDialog(BuildContext context, String serviceName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Success"),
        content: Text("$serviceName has been added to your cart successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK", style: TextStyle(color: const Color(0xFF006A4E))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerNavbar(2), // Navigate to Cart
                ),
              );
            },
            child: Text("View Cart", style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subcategory} Services'),
        backgroundColor: const Color(0xFF006A4E),
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator(color: const Color(0xFF006A4E)))
              : services.isEmpty
                  ? Center(
                      child: Text(
                          "No services available for ${widget.subcategory}"))
                  : SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 80),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Image.asset(
                                widget.imageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              Positioned.fill(
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  //color: Colors.black.withOpacity(0.3),
                                  padding: EdgeInsets.all(5),
                                  // child: Text(
                                  //   "Get your plumbing work done in minutes",
                                  //   textAlign: TextAlign.left,
                                  //   style: TextStyle(
                                  //     fontSize: 20,
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.white,
                                  //   ),
                                  // ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(services.length, (index) {
                                bool isSelected = selectedIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width /
                                            3) -
                                        16,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF006A4E)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFF006A4E), width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        services[index]['name'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          Card(
                            margin: EdgeInsets.all(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (selectedIndex != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '₹${services[selectedIndex!]['price']}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '₹${services[selectedIndex!]['dprice']}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF006A4E),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text('67% off',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ElevatedButton(
                                    onPressed: selectedIndex == null
                                        ? null
                                        : () async {
                                            int serviceId = services[
                                                    selectedIndex!]['id']
                                                as int; // Ensure it's non-nullable
                                            await addToCart(context,
                                                serviceId); // Call function with non-nullable int
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: selectedIndex != null
                                          ? const Color(0xFF006A4E)
                                          : Colors.grey,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 12),
                                    ),
                                    child: Text("ADD" , style: TextStyle(color: Colors.white),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Inclusions',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF006A4E))),
                                SizedBox(height: 5),
                                inclusionItem(
                                    'Price includes visit & diagnosis.'),
                                inclusionItem(
                                    'Repair costs will be provided after diagnosis.'),
                                inclusionItem(
                                    'Visitation charge will be adjusted in the repair cost.'),
                                inclusionItem(
                                    '100% hassle-free, 100% mess-free service.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CustomerNavbar(2)));
              },
              child: Container(
                width: double.infinity,
                height: 60,
                color: const Color(0xFF006A4E),
                child: Center(
                  child: Text(
                    selectedIndex != null
                        ? '₹${services[selectedIndex!]['dprice']}  Go to Cart'
                        : '₹0  Go to Cart',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget inclusionItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: const Color(0xFF006A4E)),
        SizedBox(width: 5),
        Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
      ],
    );
  }

 
}
