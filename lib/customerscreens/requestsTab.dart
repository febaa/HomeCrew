import 'package:flutter/material.dart';
import 'package:homecrew/customerscreens/completedBookings.dart';
import 'package:homecrew/customerscreens/customer_bookings.dart';

class RequestTabsScreen extends StatelessWidget {
  final int tabIndex;

  RequestTabsScreen(this.tabIndex); // Positional parameter

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: tabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Requests"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Service Requests"),
              Tab(text: "Accepted Requests"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Bookings(),
            CompletedBookings(),
          ],
        ),
      ),
    );
  }
}