import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customerscreens/booking_details.dart';
import 'package:homecrew/customerscreens/serviceOffers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Bookings extends StatefulWidget {
  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> bookings = [];
  late double currentAmount;
  final TextEditingController _negotiateController = TextEditingController();
  late String uid;
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    uid = authService.getCurrentUserId()!;
    fetchBookings();
  }

  Future<void> fetchBookings() async {
  final response = await supabase.from('bookings').select().eq('user_id', uid);

  if (response != null) {
    List<Map<String, dynamic>> lbookings = response
        .where((booking) => booking['status'] == "pending")
        .toList();

    // Sort bookings by `created_at` in descending order (latest first)
    lbookings.sort((a, b) => DateTime.parse(b['created_at'])
        .compareTo(DateTime.parse(a['created_at'])));

    setState(() {
      bookings = lbookings;
    });
  }
}

  Future<void> cancelBooking(int bookingId) async {
    try {
      await supabase.from('bookings').delete().eq('id', bookingId);
      fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking canceled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: bookings.isEmpty
          ? Center(
              child: Text("No bookings found",
                  style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return GestureDetector(
                  onTap: () {
                    // Navigate to the BookingDetails page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetails(booking: booking),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    margin: EdgeInsets.only(bottom: 16),
                    color: Color.fromARGB(255, 247, 247, 247),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Booking details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Category: ${booking['category']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF388E3C),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text("Date: ${booking['selected_date']}",
                                    style: TextStyle(color: Color(0xFF388E3C))),
                                Text("Time: ${booking['selected_time']}",
                                    style: TextStyle(color: Color(0xFF388E3C))),
                                Text(
                                  "Asking Price: ₹${booking['asking_price']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF388E3C),
                                  ),
                                ),
                                SizedBox(height: 16),

                                Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    if (booking["SAccepted"] == true) ...[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7, // Adjust width dynamically
            child: Text(
              "Your request has been accepted. Check the offers section to pay for the service.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              softWrap: true, // Allows text to wrap
            ),
          ),
          SizedBox(height: 10), // Spacing between text and button

          // Offers Button
          Stack(
                clipBehavior: Clip.none, // Allows the red dot to be positioned outside the button
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OffersPage(bookingId: booking['id']),
                        ),
                      );
                    },
                    child: Text(
                      'Offers',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF388E3C),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0, // Adjust position
                    right: 0, // Adjust position
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red, // Red dot color
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    ] 
    else if(booking["SNegotiated"] == true) ...[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7, // Adjust width dynamically
            child: Text(
              "You have recieved one or more counter offers from our service providers. Check the offers section to accept or negotiate the offered price. ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              softWrap: true, // Allows text to wrap
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  cancelBooking(booking['id']);
                },
                child: Text(
                  'Cancel Booking',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF388E3C),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(width: 10), // Space between buttons
              Stack(
                clipBehavior: Clip.none, // Allows the red dot to be positioned outside the button
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OffersPage(bookingId: booking['id']),
                        ),
                      );
                    },
                    child: Text(
                      'Offers',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF388E3C),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0, // Adjust position
                    right: 0, // Adjust position
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red, // Red dot color
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ],
      )
    ]
    else ...[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  cancelBooking(booking['id']);
                },
                child: Text(
                  'Cancel Booking',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF388E3C),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(width: 10), // Space between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OffersPage(bookingId: booking['id']),
                    ),
                  );
                },
                child: Text(
                  'Offers',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF388E3C),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
          if (booking["CNegotiated"] == true) ...[
            SizedBox(height: 10), // Spacing between buttons
            ElevatedButton(
              onPressed: () {
                // Handle Increase Price
                currentAmount = booking['asking_price'];
                _negotiateController.text = currentAmount.toStringAsFixed(2);





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
                              'Current Asking Price: ₹${booking['asking_price']}',
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
                                      currentAmount = (currentAmount - 10).clamp(booking['asking_price'] as double, 50000).toDouble();
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
                                      currentAmount = (currentAmount + 10).clamp(booking['asking_price'] as double, 5000).toDouble();
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
                                        await supabase.from('bookings').update({'asking_price': currentAmount}).eq('id', booking['id']);
                                        
                                        fetchBookings();
                                        
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Price Increased Successfully")),
                                        );
                                      },
                                  child: Text('Confirm',style: TextStyle(color: Colors.white),),
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













              },
              child: Text(
                'Increase Price',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF388E3C),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ],
      ),
    ],
  ],
),
                              ],
                            ),
                          ),

                          // Arrow icon indicating navigation
                          Icon(Icons.arrow_forward_ios,
                              color: Color(0xFF388E3C)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
