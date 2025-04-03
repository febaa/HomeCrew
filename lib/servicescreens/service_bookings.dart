import 'package:flutter/material.dart';

class ServiceBookings extends StatefulWidget {
  const ServiceBookings({super.key});

  @override
  State<ServiceBookings> createState() => _ServiceBookingsState();
}

class _ServiceBookingsState extends State<ServiceBookings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Bookings")),
      body: Center(
        child: Text("SERVICE BOOKINGS"),
      ),
    );
  }
}