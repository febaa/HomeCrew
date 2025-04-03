import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customerscreens/thankyou.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;
  Map<String, List<Map<String, dynamic>>> groupedCartItems = {};
  late String uid;
  int currentStep = 0;
  String selectedCategory = "";
  int? selectedAddressId;
  Map<String, dynamic>? selectedAddress;
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  String selectedTime = "";
  late double currentAmount;
  final TextEditingController _negotiateController = TextEditingController();

  List<DateTime> getNext7Days() {
    return List.generate(
        7, (index) => DateTime.now().add(Duration(days: index)));
  }

  List<String> timeSlots = [
    "10:00 AM - 12:00 PM",
    "12:00 PM - 2:00 PM",
    "2:00 PM - 4:00 PM",
    "4:00 PM - 6:00 PM",
    "6:00 PM - 8:00 PM",
    "8:00 PM - 10:00 PM"
  ];

  // Function to move to next step
  void goToNextStep() {
    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
    }
  }


  Widget getStepUI() {
    switch (currentStep) {
      case 0:
        return Expanded(
          child: groupedCartItems.isEmpty
              ? const Center(
                  child: Text(
                    "Your cart is empty.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: groupedCartItems.entries.map((entry) {
                    final category = entry.key;
                    final services = entry.value;

                    // Calculate total cost for the category
                    double totalCategoryPrice = services.fold(0, (sum, item) {
                      return sum +
                          (item['services']['dprice'] * item['quantity']);
                    });

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 10,
                      margin: const EdgeInsets.only(bottom: 16),
                      shadowColor: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 10, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Title
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const Divider(thickness: 1, color: Colors.grey),

                            // Services inside category
                            Column(
                              children: services.map((item) {
                                final service = item['services'];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Service Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Full-width Service Name
                                            Text(
                                              '${service['subcategory']} - ${service['name']}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF333333),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),

                                            // Bookings
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    color: Colors.orange,
                                                    size: 18),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "(${service['bookings']} bookings)",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),

                                            // Pricing and Quantity Controls in a Row
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Prices on the Left
                                                Row(
                                                  children: [
                                                    Text(
                                                      "₹${service['dprice']}",
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "₹${service['price']}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // Quantity Controls and Delete Button on the Right
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 28, // Reduced size
                                                      height:
                                                          28, // Reduced size
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: IconButton(
                                                        iconSize:
                                                            16, // Smaller icon size
                                                        icon: const Icon(
                                                            Icons.remove,
                                                            color:
                                                                Colors.black),
                                                        onPressed: () =>
                                                            updateQuantity(
                                                                item['id'],
                                                                item['quantity'] -
                                                                    1),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                              8), // Adjusted spacing
                                                      child: Text(
                                                        item['quantity']
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 28, // Reduced size
                                                      height:
                                                          28, // Reduced size
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: IconButton(
                                                        iconSize:
                                                            16, // Smaller icon size
                                                        icon: const Icon(
                                                            Icons.add,
                                                            color:
                                                                Colors.black),
                                                        onPressed: () =>
                                                            updateQuantity(
                                                                item['id'],
                                                                item['quantity'] +
                                                                    1),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      iconSize:
                                                          20, // Slightly smaller delete icon
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () =>
                                                          removeFromCart(
                                                              item['id']),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                            const Divider(thickness: 1, color: Colors.grey),

                            // Total Price for the Category
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Text(
                                "Total: ₹${totalCategoryPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Divider(thickness: 1, color: Colors.grey),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Negotiate Button
                                // Expanded(
                                //   child: ElevatedButton(
                                //     onPressed: () {
                                //       // Add negotiation logic here
                                //     },
                                //     style: ElevatedButton.styleFrom(
                                //       backgroundColor: Colors.grey,
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius:
                                //             BorderRadius.circular(8),
                                //       ),
                                //       padding: const EdgeInsets.symmetric(
                                //           vertical: 12),
                                //     ),
                                //     child: const Text(
                                //       "Negotiate",
                                //       style: TextStyle(
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.white),
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(width: 12),

                                // Book Now Button
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedCategory = category;
                                            currentAmount = calculateTotalForCategory();
                                            _negotiateController.text = currentAmount.toStringAsFixed(2);
                                        goToNextStep(); // Then move to the next step
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF006A4E),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                    ),
                                    child: const Text(
                                      "Next",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        );
      case 1:
        return Expanded(
          child: Column(
            children: [
              Expanded(
                // Ensures list takes available space
                child: isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator()) // Show loading state
                    : addresses.isEmpty
                        ? Center(
                            child: Text("No address found",
                                style: TextStyle(
                                    fontSize:
                                        16))) // Show message when no addresses
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final addr = addresses[index];
                              final isSelected = selectedAddressId ==
                                  addr['id']; // Check if this card is selected

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAddressId =
                                        addr['id']; // Store selected address ID
                                    fetchAddressFromSupabase(selectedAddressId!);
                                    goToNextStep();
                                  });
                                },
                                child: Card(
                                  margin: EdgeInsets.only(bottom: 12),
                                  elevation: isSelected
                                      ? 6
                                      : 4, // Highlight if selected
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey, // Border color change
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        "${addr['fullName']} - ${addr['phone']}"),
                                    subtitle: Text(
                                        "${addr['addressLine']}, ${addr['city']}, ${addr['state']} - ${addr['pincode']}"),
                                    trailing: IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await supabase
                                            .from('addresses')
                                            .delete()
                                            .eq('id', addr['id']);
                                        fetchAddresses(); // Refresh UI
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: showAddAddressDialog,
                    child: Text("Add Address"),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 2:
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select Date Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Select Date",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Date Selection
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  height: 117, // Increased height to avoid overflow
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: getNext7Days().map((date) {
                      bool isSelected = date.day == selectedDate.day;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          width: 85, // Adjusted width
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Color(0xFF006A4E) : Colors.white,
                            border:
                                Border.all(color: Color(0xFF006A4E), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('MMM').format(date),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat('d').format(date),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat('E').format(date),
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              SizedBox(height: 2),

              // Select Time Slot Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Select Time Slot",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Time Slot Selection in Grid (2 per row)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // Prevent grid from scrolling
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 items per row
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3, // Adjusted size of boxes
                  ),
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    bool isSelected = timeSlots[index] == selectedTime;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTime = timeSlots[index];
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFF006A4E) : Colors.white,
                          border:
                              Border.all(color: Color(0xFF006A4E), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          timeSlots[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: SizedBox(
                  width: double.infinity, // Takes the full width
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedDate != null && selectedTime.isNotEmpty) {
                        setState(() {
                          goToNextStep(); // Move to the next step
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select date and time"),
                            backgroundColor: Color(0xFF006A4E),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006A4E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 3:
        return Expanded(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      "Booking Summary",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(thickness: 1.2, color: Colors.grey.shade400),
                  SizedBox(height: 8),
                  // Category
                  Text(
                    "Service Category: $selectedCategory",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 15),

                  // Services Table
                  if (groupedCartItems.containsKey(selectedCategory)) ...[
                    Table(
                      columnWidths: {
                        0: FlexColumnWidth(5), // Service Name
                        1: FlexColumnWidth(1), // Quantity
                        2: FlexColumnWidth(1.1), // Price
                      },
                      border: TableBorder.symmetric(
                        inside:
                            BorderSide(width: 0.5, color: Colors.grey.shade300),
                      ),
                      children: [
                        TableRow(
                          decoration:
                              BoxDecoration(color: Colors.grey.shade200),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text("Service",
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text("Qty",
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text("Price",
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        for (var item in groupedCartItems[selectedCategory]!)
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                child: Text(
                                    "${item['services']['subcategory']} - ${item['services']['name']}",
                                    textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("${item['quantity']}",
                                    textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("₹${item['services']['dprice']}",
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ] else
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "No services available under this category.",
                        style: TextStyle(fontSize: 16, color: Colors.redAccent),
                      ),
                    ),

                  SizedBox(height: 7),
                  Divider(thickness: 1.2, color: Colors.grey.shade400),
                  SizedBox(height: 7),
                  // Date & Time Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Selected Date:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(DateFormat('dd MMM yyyy').format(selectedDate),
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Selected Time:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(selectedTime, style: TextStyle(fontSize: 16)),
                    ],
                  ),

                  SizedBox(height: 10),
                  Divider(thickness: 1.2, color: Colors.grey.shade400),
                  SizedBox(height: 4),

                  // Address Section
                  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Address Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),

        // Check if selectedAddress is null and fetch the address if necessary
        selectedAddress == null
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Fetching address...", style: TextStyle(fontSize: 14, color: Colors.black54)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${selectedAddress!['fullName']} | ${selectedAddress!['phone']}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text(
                    "${selectedAddress!['addressLine']}, ${selectedAddress!['city']}, ${selectedAddress!['state']} - ${selectedAddress!['pincode']}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ],
    ),

                  SizedBox(height: 7),
                  Divider(thickness: 1.2, color: Colors.grey.shade400),

                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        "₹${calculateTotalForCategory()}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF006A4E),),
                      ),
                    ],
                  ),
                  Divider(thickness: 1.2, color: Colors.grey.shade400),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Negotiate Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Add negotiation logic here
                            _showNegotiationDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Negotiate",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Book Now Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              // Ensure selectedCategory exists in groupedCartItems
                              if (!groupedCartItems
                                      .containsKey(selectedCategory) ||
                                  groupedCartItems[selectedCategory]!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "No services found in the selected category!"),
                                      backgroundColor: Colors.red),
                                );
                                return;
                              }

                              // Prepare services data with only service IDs and quantities
                              List<Map<String, dynamic>> servicesList =
                                  groupedCartItems[selectedCategory]!
                                      .map((item) => {
                                            "service_id": item['services']
                                                ['id'], // Store service ID
                                            "quantity": item[
                                                'quantity'] // Store quantity
                                          })
                                      .toList();

                              // Ensure required fields are not empty
                              if (selectedDate == null ||
                                  selectedTime.isEmpty ||
                                  selectedAddressId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Please select date, time, and address."),
                                      backgroundColor: Colors.red),
                                );
                                return;
                              }

                              // Prepare booking data
                              final bookingData = {
                                "user_id":
                                    uid, // Replace with actual user ID from authentication
                                "category": selectedCategory,
                                "services":
                                    servicesList, // Store service IDs & quantities
                                "selected_date": selectedDate.toIso8601String(),
                                "selected_time": selectedTime,
                                "asking_price": calculateTotalForCategory(),
                                "address_id": selectedAddressId,
                                "CNegotiated": false,
                                "SNegotiated": false,
                                "total_amount": calculateTotalForCategory(),
                                "SAccepted": false,
                                "status": "pending"
                              };

                              // Insert into Supabase
                              final response = await supabase
                                  .from('bookings')
                                  .insert([bookingData]);

                              removeCategoryFromCart(selectedCategory);

                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ThankYouPage()));
                            } catch (error) {
                              // Handle errors properly
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Booking failed: $error"),
                                    backgroundColor: Colors.red),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006A4E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            "Book Now",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return const Center(child: Text("Error: Invalid Step"));
    }
  }

   // Method to show the negotiation dialog
  void _showNegotiationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Negotiate Price',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF006A4E),
                  ),
                ),
                SizedBox(height: 16),

                // Displaying the initial amount
                Text(
                  'Initial Amount: ₹${calculateTotalForCategory().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),

                // Row with + and - buttons on the sides of the text field
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrease Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentAmount = (currentAmount - 10).clamp(0, calculateTotalForCategory());
                          _negotiateController.text = currentAmount.toStringAsFixed(2);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006A4E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.remove, color: Colors.white, size: 24),
                      ),
                    ),
                    SizedBox(width: 16),

                    // TextField for Negotiated Amount
                    Container(
                      width: 120, // Reduced width for the text field
                      child: TextField(
                        controller: _negotiateController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Negotiated',
                          labelStyle: TextStyle(color: const Color(0xFF006A4E),),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          setState(() {
                            currentAmount = double.tryParse(value) ?? 0; // Update current amount
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),

                    // Increase Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentAmount = (currentAmount + 10).clamp(0, calculateTotalForCategory());
                          _negotiateController.text = currentAmount.toStringAsFixed(2);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006A4E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Display the updated negotiated amount
                Text(
                  'Negotiated Amount: ₹${currentAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF006A4E),
                  ),
                ),
                SizedBox(height: 24),

                // Buttons at the bottom
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),

                    // Confirm button
                    ElevatedButton(
                      onPressed: () async {
                            try {
                              // Ensure selectedCategory exists in groupedCartItems
                              if (!groupedCartItems
                                      .containsKey(selectedCategory) ||
                                  groupedCartItems[selectedCategory]!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "No services found in the selected category!"),
                                      backgroundColor: Colors.red),
                                );
                                return;
                              }

                              // Prepare services data with only service IDs and quantities
                              List<Map<String, dynamic>> servicesList =
                                  groupedCartItems[selectedCategory]!
                                      .map((item) => {
                                            "service_id": item['services']
                                                ['id'], // Store service ID
                                            "quantity": item[
                                                'quantity'] // Store quantity
                                          })
                                      .toList();

                              // Ensure required fields are not empty
                              if (selectedDate == null ||
                                  selectedTime.isEmpty ||
                                  selectedAddressId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Please select date, time, and address."),
                                      backgroundColor: Colors.red),
                                );
                                return;
                              }

                              // Prepare booking data
                              final bookingData = {
                                "user_id":
                                    uid, // Replace with actual user ID from authentication
                                "category": selectedCategory,
                                "services":
                                    servicesList, // Store service IDs & quantities
                                "selected_date": selectedDate.toIso8601String(),
                                "selected_time": selectedTime,
                                "asking_price": currentAmount,
                                "address_id": selectedAddressId,
                                "CNegotiated": true,
                                "SNegotiated": false,
                                "total_amount": calculateTotalForCategory(),
                                "SAccepted": false,
                                "status": "pending"
                              };

                              // Insert into Supabase
                              final response = await supabase
                                  .from('bookings')
                                  .insert([bookingData]);

                              removeCategoryFromCart(selectedCategory);

                              

                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ThankYouPage()));
                            } catch (error) {
                              // Handle errors properly
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Booking failed: $error"),
                                    backgroundColor: Colors.red),
                              );
                            }
                          },
                      child: Text('Confirm', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006A4E), // Button color
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double calculateTotalForCategory() {
    if (!groupedCartItems.containsKey(selectedCategory)) return 0.0;

    return groupedCartItems[selectedCategory]!.fold(0.0, (sum, item) {
      return sum + (item['services']['dprice'] * item['quantity']);
    });
  }

  Future<void> fetchAddressFromSupabase(int addressId) async {
    final supabase = Supabase.instance.client;

    final response =
        await supabase.from('addresses').select().eq('id', addressId).single();

    if (response == null) {
      return null;
    }

    setState(() {
      selectedAddress = response; // Store the selected address here
    });
  }

  @override
  void initState() {
    super.initState();
    uid = authService.getCurrentUserId()!;
    loadCartItems();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await supabase
        .from('addresses')
        .select('*')
        .eq('userId', uid)
        .order('created_at', ascending: false);

    setState(() {
      addresses = response;
      isLoading = false;
    });
  }

  void showAddAddressDialog() {
    String fullName = '';
    String phone = '';
    String address = '';
    String city = '';
    String state = '';
    String pincode = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Address"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Full Name"),
                  onChanged: (value) => fullName = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Phone"),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => phone = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Address"),
                  onChanged: (value) => address = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "City"),
                  onChanged: (value) => city = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "State"),
                  onChanged: (value) => state = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Pincode"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => pincode = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Submit"),
              onPressed: () async {
                await addAddress(
                    fullName, phone, address, city, state, pincode);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addAddress(String fullName, String phone, String address,
      String city, String state, String pincode) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final newAddress = {
      "userId": uid,
      "fullName": fullName,
      "phone": phone,
      "addressLine": address,
      "city": city,
      "state": state,
      "pincode": pincode,
    };

    await supabase.from('addresses').insert(newAddress);
    fetchAddresses(); // Refresh UI
  }

  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print("User not logged in");
      return [];
    }

    try {
      final response = await supabase
          .from('cart')
          .select('*, services(*)')
          .eq('userId', uid)
          .order('id', ascending: true);

      return response;
    } catch (error) {
      print("Error fetching cart: $error");
      return [];
    }
  }

  Future<void> loadCartItems() async {
    final items = await fetchCartItems();

    // Group services by category
    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in items) {
      final category = item['services']['category'] ?? 'Other';
      if (!groupedItems.containsKey(category)) {
        groupedItems[category] = [];
      }
      groupedItems[category]!.add(item);
    }

    setState(() {
      groupedCartItems = groupedItems;
    });
  }

  Future<void> updateQuantity(int cartId, int newQuantity) async {
    if (newQuantity <= 0) {
      await supabase.from('cart').delete().eq('id', cartId);
    } else {
      await supabase
          .from('cart')
          .update({'quantity': newQuantity}).eq('id', cartId);
    }
    loadCartItems();
  }

  Future<void> removeFromCart(int cartId) async {
    await supabase.from('cart').delete().eq('id', cartId);
    loadCartItems();
  }


  Future<void> removeCategoryFromCart(String category) async {
  if (groupedCartItems.containsKey(category)) {
    List<int> cartIds = groupedCartItems[category]!
        .map((item) => item['id'] as int) // Ensure id is int
        .toList();

    if (cartIds.isNotEmpty) {
      await supabase.from('cart').delete().filter('id', 'in', cartIds);
    }
  }
  loadCartItems();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Your Cart",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF006A4E),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  double stepSize = width / 5; // Dynamic spacing for steps

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Connecting Line (Behind the Circles)
                      Positioned(
                        top: 15, // Position at circle height
                        left: stepSize / 2,
                        right: stepSize / 1.5,
                        child: Container(
                          height: 3,
                          width: double.infinity,
                          color: Colors.grey.shade400,
                        ),
                      ),

                      // Steps
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          bool isSelected = currentStep == index;
                          bool isCompleted = currentStep > index;

                          return Column(
                            children: [
                              // Step Circle
                              Container(
                                width: width * 0.08, // Responsive size
                                height: width * 0.08,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected || isCompleted
                                      ? const Color(0xFF006A4E)
                                      : Colors.grey,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.04, // Responsive font
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  height: 8), // Space between circle & text

                              // Step Label
                              Text(
                                [
                                  "Cart",
                                  "Address",
                                  "Schedule",
                                  "Confirm"
                                ][index],
                                style: TextStyle(
                                  fontSize: width * 0.035, // Responsive font
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? const Color(0xFF006A4E) : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),

              // Dummy button to navigate through steps
              // ElevatedButton(
              //   onPressed: () {
              //     setState(() {
              //       if (currentStep < 3) {
              //         currentStep++;
              //       }
              //     });
              //   },
              //   child: const Text("Next Step"),
              // ),
              const Divider(thickness: 1),
              getStepUI(),
            ],
          ),
        ));
  }
}
