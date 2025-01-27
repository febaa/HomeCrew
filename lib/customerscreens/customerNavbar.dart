import 'package:flutter/material.dart';
import 'package:homecrew/customerscreens/customer_bookings.dart';
import 'package:homecrew/customerscreens/customer_wallet.dart';
import 'package:homecrew/customerscreens/customer_homescreen.dart';
import 'package:homecrew/customerscreens/my_account.dart';

class CustomerNavbar extends StatefulWidget {
  final int page;
  const CustomerNavbar(this.page);

  @override
  State<CustomerNavbar> createState() => _CustomerNavbarState();
}

class _CustomerNavbarState extends State<CustomerNavbar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.page; // Initialize _currentIndex with the passed page
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CustomerHomePage(),
      CustomerWallet(),
      CustomerBookings(),
      CustomerAccountPage()
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
                      child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                    )
                  : Icon(Icons.account_balance_wallet_outlined),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A4E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.calendar_today, color: Colors.white),
                    )
                  : Icon(Icons.calendar_today),
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
