import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingDetails extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetails({Key? key, required this.booking}) : super(key: key);

  @override
  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> services = [];
  Map<String, dynamic>? address;

  @override
  void initState() {
    super.initState();
    fetchServices();
    fetchAddress();
  }

  Future<void> fetchServices() async {
    List<dynamic> serviceIds = widget.booking['services'];

    List<Map<String, dynamic>> fetchedServices = [];
    for (var service in serviceIds) {
      final response = await supabase
          .from('services')
          .select()
          .eq('id', service['service_id'])
          .single();
      if (response != null) {
        fetchedServices.add({
          'name': response['name'],
          'subcategory': response['subcategory'],
          'price': response['dprice'],
          'quantity': service['quantity'],
        });
      }
    }

    setState(() {
      services = fetchedServices;
    });
  }

  Future<void> fetchAddress() async {
    final addressId = widget.booking['address_id'];
    final response = await supabase.from('addresses').select().eq('id', addressId).single();

    if (response != null) {
      setState(() {
        address = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      appBar: AppBar(title: Text("Booking Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Text(
              "${booking['category']}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 10),

            // Services Table
            Text("Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            Table(
              border: TableBorder.all(color: Colors.grey.shade400),
              columnWidths: {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  children: [
                    _tableHeader("Service"),
                    _tableHeader("Quantity"),
                    _tableHeader("Price"),
                  ],
                ),
                ...services.map((service) {
                  return TableRow(children: [
                    _tableCell("${service['subcategory']} - ${service['name']}"),
                    _tableCell("${service['quantity']}"),
                    _tableCell("₹${service['price']}"),
                  ]);
                }).toList(),
              ],
            ),
            SizedBox(height: 20),

            // Address Section
            Text("Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            address == null
                ? CircularProgressIndicator()
                : Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${address!['fullName']} (${address!['phone']})",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text("${address!['addressLine']}, ${address!['city']}"),
                        Text("${address!['state']} - ${address!['pincode']}"),
                      ],
                    ),
                  ),
            SizedBox(height: 20),

            // Booking Summary
            Text("Booking Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            _summaryRow("Date", "${booking['selected_date']}"),
            _summaryRow("Time", "${booking['selected_time']}"),
            _summaryRow("Total Amount", "₹${booking['total_amount']}"),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }

  Widget _tableCell(String text) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Align(
      alignment: Alignment.centerLeft, // Left-align text
      child: Text(
        text,
        style: TextStyle(fontSize: 14),
      ),
    ),
  );
}

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
