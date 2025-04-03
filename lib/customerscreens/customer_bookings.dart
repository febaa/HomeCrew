import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final response = await supabase.from('bookings').select();
    if (response != null) {
      setState(() {
        bookings = List<Map<String, dynamic>>.from(response);
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
    ] else ...[
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
