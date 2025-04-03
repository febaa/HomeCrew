import 'package:flutter/material.dart';
import 'package:homecrew/servicescreens/service_account.dart';
import 'package:homecrew/servicescreens/service_bookings.dart';
import 'package:homecrew/servicescreens/service_homescreen.dart';

class ServiceNavbar extends StatefulWidget {
  final int page;
  const ServiceNavbar(this.page);

  @override
  State<ServiceNavbar> createState() => _ServiceNavbarState();
}

class _ServiceNavbarState extends State<ServiceNavbar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        widget.page; // Initialize _currentIndex with the passed page
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ServiceHomescreen(),
      ServiceBookings(),
      ServiceMyAccount()
    ];
    return MaterialApp(
      home: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _selectedIndex == 0
                  ? Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A4E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.home, color: Colors.white),
                    )
                  : Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A4E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.white),
                    )
                  : Icon(Icons.account_balance_wallet_outlined),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A4E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, color: Colors.white),
                    )
                  : Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
