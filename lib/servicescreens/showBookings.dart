import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customerscreens/booking_details.dart';
import 'package:homecrew/servicescreens/SP_booking_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class showBookings extends StatefulWidget {

  @override
  _showBookingsState createState() => _showBookingsState();
}

class _showBookingsState extends State<showBookings> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> bookings = [];
  List<String> serviceProviderSkills = [];
  late String uid;
  final authService = AuthService();
  late double currentAmount;
  final TextEditingController _negotiateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    uid = authService.getCurrentUserId()!;
    fetchServiceProviderSkills();
  }

  Future<Map<String, dynamic>?> fetchOffer(String uid, Map<String, dynamic> booking) async {
  final response = await supabase
      .from('offers')
      .select()
      .eq('service_provider_id', uid)
      .eq('booking_id', booking['id'])
      .maybeSingle(); // Fetch a single row if exists, else returns null
  return response;
}

  // 📌 Fetch service provider skills from sp_skills table
  Future<void> fetchServiceProviderSkills() async {
    final response = await supabase
        .from('sp_skills')
        .select('categories')
        .eq('id', uid)
        .single(); // Fetch only the logged-in provider’s skills

    if (response != null && response['categories'] != null) {
      List<String> skills = List<String>.from(response['categories']);
      setState(() {
        serviceProviderSkills = skills;
      });
      fetchBookings();
    }
  }

  // 📌 Fetch bookings and filter them based on service provider skills
  Future<void> fetchBookings() async {
  final response = await supabase.from('bookings').select();

  if (response != null) {
    List<Map<String, dynamic>> filteredBookings = response
        .where((booking) =>
            serviceProviderSkills.contains(booking['category']) &&
            booking['status'] == "pending") // Only show bookings where SAccepted is false
        .toList();

    // Sort bookings by `created_at` in descending order (latest first)
    filteredBookings.sort((a, b) => DateTime.parse(a['created_at'])
        .isBefore(DateTime.parse(b['created_at']))
        ? 1
        : -1);

    setState(() {
      bookings = filteredBookings;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Service Requests")),
      body: bookings.isEmpty
          ? Center(
              child: Text(
                "No bookings found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 5,
                  color: Color.fromARGB(255, 247, 247, 247),
                  child: ListTile(
                    title: Text(
                      "Category: ${booking['category']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: 
                    FutureBuilder(future: fetchOffer(uid, booking), builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator()); // Show loader while fetching
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading data"));
                    }

                    final offer = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text("Date: ${booking['selected_date']}"),
                        Text("Time: ${booking['selected_time']}"),
                        Text("Asking Price: ₹${offer != null ? offer['asking_price'] : booking['asking_price']}"),
                        SizedBox(height: 16),

                                
                                Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Conditional Text Message
    Text(
  () {
    if (offer!=null && offer['accepted'] == true && offer['negotiated']==false) {
      return "You have accepted this booking, please wait until the customer makes payment and confirms the booking.";
    } else if (offer != null && offer['negotiated'] == false) {
      return "Your negotiated offer has been forwarded to the customer, please wait until the customer responds.";
    } else if (offer != null && offer['negotiated'] == true) {
      return "Customer has made a counter offer.";
    } else if (offer == null && booking["CNegotiated"] == false) {
      return "Customer has posted request on MRP, so negotiation is not allowed.";
    } else {
      return "You can negotiate to increase the price.";
    }
  }(),
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.grey[700],
  ),
),
    SizedBox(height: 10), // Spacing between text and buttons

    // Conditional Buttons
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
      if(offer!=null && offer['accepted'] == true && offer['negotiated']==false)...[

      ]
      else if (offer != null && offer['negotiated'] == false)...[]
      else if(offer == null && booking["CNegotiated"] == false)...[
              ElevatedButton(
  onPressed: () async {

      await supabase.from('offers').insert({
        'service_provider_id': uid,
        'asking_price': booking["asking_price"],
        'accepted': true,
        'booking_id': booking['id'],
        'negotiated': false
      });

      await supabase
        .from('bookings')
        .update({'SAccepted': true})
        .eq('id', booking['id']);

      fetchBookings();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Offer accepted successfully!")),
        );

  },
  child: Text(
    'Accept',
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
            ]
          else if (offer != null && offer['negotiated'] == true)...[






            ElevatedButton(
                onPressed: () async {

                  await supabase.from('offers').update({
                    'accepted': true,
                    'negotiated': false
                  }).eq('booking_id', booking['id']);

                  await supabase
                    .from('bookings')
                    .update({'SAccepted': true})
                    .eq('id', booking['id']);

                  fetchBookings();

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Offer accepted, wait for the customer to confirm")),
                    );

              },
                            child: Text(
                              'Accept',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF006A4E),
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

                          SizedBox(width: 10),

                          ElevatedButton(
                            onPressed: () {
                              
                              if (offer['offercount'] >= 4) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Negotiation Limit Reached"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return; // Stop execution if limit is reached
                                  }



                              currentAmount = offer['asking_price'];
                              _negotiateController.text = currentAmount.toStringAsFixed(2);



                              // Handle Negotiate action
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
                                                      await supabase.from('offers').update({
                                                        'asking_price': currentAmount,
                                                        'negotiated': false
                                                      }).eq('booking_id', booking['id']);
                                                      
                                                      await supabase.from('bookings').update({'SNegotiated': true}).eq('id', booking['id']);

                                                      await supabase.from('offers').update({
                                                          'offercount': supabase.from('offers').select('offercount').eq('id', offer['id']).single().then((res) => res['offercount'] + 1)
                                                        }).eq('id', offer['id']);

                                                      fetchBookings();
                                                      
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Offer accepted successfully!")),
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
                            child: Text('Negotiate', style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF006A4E),
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
                          















          ]


          




          else...[
              ElevatedButton(
                onPressed: () async {

      await supabase.from('offers').insert({
        'service_provider_id': uid,
        'asking_price': booking["asking_price"],
        'accepted': true,
        'booking_id': booking['id'],
        'negotiated': false
      });

      await supabase
        .from('bookings')
        .update({'SAccepted': true})
        .eq('id', booking['id']);

      fetchBookings();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Offer accepted successfully!")),
        );

  },
                child: Text(
                  'Accept',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006A4E),
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
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {






                  currentAmount = booking['asking_price'];
                  _negotiateController.text = currentAmount.toStringAsFixed(2);










                  // Handle Negotiate action
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
                            
                            await supabase.from('offers').insert({
                              'service_provider_id': uid,
                              'asking_price': currentAmount,
                              'accepted': false,
                              'booking_id': booking['id'],
                              'negotiated': false,
                              'offercount': 1
                            });

                            await supabase.from('bookings').update({'SNegotiated': true}).eq('id', booking['id']);
                            
                            

                            fetchBookings();
                            
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Offer accepted successfully!")),
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
                  'Negotiate',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006A4E),
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
      ]
    ),
  ],
)
                      ],
                    );
                    }),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SPBookingDetails(booking: booking),
                        ),);

                      
                    },
                  ),
                );
              },
            ),
    );
  }
}
