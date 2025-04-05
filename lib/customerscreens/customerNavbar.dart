import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homecrew/customerscreens/cart.dart';
import 'package:homecrew/customerscreens/customer_bookings.dart';
import 'package:homecrew/customerscreens/customer_homescreen.dart';
import 'package:homecrew/customerscreens/my_account.dart';
import 'package:homecrew/customerscreens/requestsTab.dart';

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
      RequestTabsScreen(0),
      Cart(),
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
                      child: Icon(FontAwesomeIcons.book, color: Colors.white),
                    )
                  : Icon(FontAwesomeIcons.book),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A4E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(FontAwesomeIcons.bagShopping, color: Colors.white),
                    )
                  : Icon(FontAwesomeIcons.bagShopping),
              label: 'Cart',
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
