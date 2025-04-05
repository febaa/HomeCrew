import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customerscreens/booking_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompletedBookings extends StatefulWidget {
  @override
  _CompletedBookingsState createState() => _CompletedBookingsState();
}

class _CompletedBookingsState extends State<CompletedBookings> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> bookings = [];
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
    List<Map<String, dynamic>> lbookings = [];

    for (var booking in response) {
      if (booking['status'] == "completed") {
        // Fetch provider details from 'users' table
        final providerResponse = await supabase
            .from('users')
            .select()
            .eq('uid', booking['service_provider_id'])
            .single();

        if (providerResponse != null) {
          booking['provider_name'] = providerResponse['name'];
          booking['provider_age'] = providerResponse['age'];
          booking['provider_gender'] = providerResponse['gender'];
        }

        lbookings.add(booking);
      }
    }

    // Sort by newest booking first
    lbookings.sort((a, b) =>
        DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

    setState(() {
      bookings = lbookings;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bookings.isEmpty
          ? Center(
              child: Text(
                "No completed bookings found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return GestureDetector(
                  onTap: () {
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
                    color: Color.fromARGB(255, 240, 240, 240),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Category: ${booking['category']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF455A64),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Provider: ${booking['provider_name']}, ${booking['provider_age']} yrs, ${booking['provider_gender']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF37474F),
                                ),
                                ),
                                SizedBox(height: 8),
                                Text("Date: ${booking['selected_date']}", style: TextStyle(color: Color(0xFF455A64))),
                                Text("Time: ${booking['selected_time']}", style: TextStyle(color: Color(0xFF455A64))),
                                Text(
                                  "Asking Price: ₹${booking['asking_price']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF455A64),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
