import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customer_or_service.dart';
import 'package:homecrew/customerscreens/cart.dart';
import 'package:homecrew/customerscreens/my_account.dart';
import 'package:homecrew/customerscreens/service_pages/servicePage.dart';
import 'package:homecrew/customerscreens/service_pages/hair_salon.dart';
import 'package:homecrew/customerscreens/service_pages/manicure.dart';
import 'package:homecrew/customerscreens/service_pages/plumber.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final authService = AuthService();
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;
  late String uid;
  String name = "";
  //int mobile = 0;

  @override
  void initState() {
    super.initState();
    uid = authService.getCurrentUserId()!; // Get current user ID
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final response = await supabase
          .from('users') // Replace 'users' with your table name
          .select('name') // Select the desired columns
          .eq('uid', uid) // Filter by UID
          .single(); // Fetch a single row

      if (response != null) {
        setState(() {
          name = response['name'] ?? 'No Name';
          //mobile = response['mobile'] ?? 0;
        });
      } else {
        setState(() {
          name = "Not Found";
        });
      }
    } catch (error) {
      setState(() {
        name = "Error";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $error')),
      );
    }
  }

  Widget _BuildCategoryCard(
      String imageUrl, String title, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Display the image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imageUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int _currentIndex = 0;
  final List<String> _images = [
    'assets/images/HomePage1.png',
    'assets/images/HomePage2.png',
    'assets/images/HomePage3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150), // Increased height
          child: AppBar(
              backgroundColor: const Color(0xFF006A4E), // Green color
              elevation: 0,
              flexibleSpace: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align content at the bottom
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hello, ' + name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Mumbai, 400001',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.search, color: Colors.grey),
                          hintText: 'What service are you looking for?',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Cart(
                            )));
                  },
                  child: const Icon(Icons.shopping_cart, color: Colors.white),
                ),
              ]),
        ),

        //Service categories
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15, bottom: 15, left: 5, right: 5),
                  child: CarouselSlider(
                    items: _images.map((image) {
                      return Stack(
                        children: [
                          ClipRRect(
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  0.92, // Full width
                              height: 200, // Fixed height
                              decoration: BoxDecoration(
                                color: Colors.grey[
                                    300], // Background color if image fails
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset(image, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            bottom: 10, // Adjust this for dot positioning
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _images.asMap().entries.map((entry) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentIndex == entry.key
                                        ? Colors.blue
                                        : Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 200, // Adjust as needed
                      autoPlay: true,
                      viewportFraction:
                          1.0, // Full width (no adjacent cards visible)
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, bottom: 13),
                  width: double.infinity,
                  child: Text(
                    "All Services",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _BuildCategoryCard('assets/images/Service_person.png',
                          "Cook,\nDriver & Guard", () {
                        _showModalBottomSheet(context, "CookDriverGuard");
                      }),
                      _BuildCategoryCard(
                          'assets/images/Carpentary_repairs.png', "Carpentary",
                          () {
                        _showModalBottomSheet(context, "CarpentaryWorks");
                      }),
                      _BuildCategoryCard(
                          'assets/images/AC & appliances repairs.png',
                          "Appliances", () {
                        _showModalBottomSheet(context, "AppliancesRepair");
                      }),
                      _BuildCategoryCard(
                        'assets/images/Plumbing.png',
                        "Plumbing",
                        () {
                        _showModalBottomSheet(context, "Plumber"); 
                        },
                      ),
                      _BuildCategoryCard(
                          'assets/images/Painting.png', "Painting", () {
                        _showModalBottomSheet(context, "Painting");
                      }),
                      _BuildCategoryCard(
                          'assets/images/Cleaning.png', "Cleaning", () {
                        _showModalBottomSheet(context, "Cleaning");
                      }),
                      _BuildCategoryCard(
                          'assets/images/Electrician.png', "Electrical", () {
                        _showModalBottomSheet(context, "Electrical");
                      }),
                      _BuildCategoryCard('assets/images/Women_salon&spa.png',
                          "Women's\nSalon & Spa", () {
                        _showModalBottomSheet(context, "WomenSalon");
                      }),
                      _BuildCategoryCard('assets/images/Men_salon&spa.png',
                          "Men's\nSalon & Spa", () {
                        _showModalBottomSheet(context, "MenSalon");
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows dynamic height adjustment
      builder: (BuildContext context) {
        Widget content;
        switch (category) {
          case 'WomenSalon':
            content = _buildWomenSalonContent();
            break;
          case 'MenSalon':
            content = _buildMenSalonContent();
            break;
          case 'CarpentaryWorks':
            content = _buildCarpentaryWorksContent();
            break;
          case 'AppliancesRepair':
            content = _buildAppliancesRepairContent();
            break;
          case 'CookDriverGuard':
            content = _buildCookDriverGuardcontent();
            break;
          case 'Painting':
            content = _buildPaintingContent();
            break;
          case 'Cleaning':
            content = _buildCleaningContent();
            break;
          case 'Electrical':
            content = _buildElectricalContent();
            break;
          case 'Plumber':
            content = _buildPlumbingContent();
            break;
          default:
            content = _buildAppliancesRepairContent();
        }
        return Container(
          width: double.infinity, // Full-width modal
          padding: EdgeInsets.all(16.0),
          child: content, // Dynamic content
        );
      },
    );
  }

  Widget _buildCookDriverGuardcontent() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allows dynamic height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cook\'s Driver and Guard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10, // Adjust vertical spacing if needed
              alignment: WrapAlignment.center,
              children: [
                _buildServiceCard('assets/images/Cook.png', "Cook", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Cook, Driver & Guard",
                              subcategory: "Cook",
                              imageUrl: 'assets/images/CookImg.png',
                            )));
                }),
                _buildServiceCard('assets/images/Driver.png', "Driver", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Cook, Driver & Guard",
                              subcategory: "Driver",
                              imageUrl: 'assets/images/DriverImg.png',
                            )));
                }),
                _buildServiceCard('assets/images/Guard.png', 'Guard', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Cook, Driver & Guard",
                              subcategory: "Guard",
                              imageUrl: 'assets/images/Security.jpg',
                            )));
                }),
              ],
            ),
            SizedBox(height: 20),
          ],
        ));
  }

  Widget _buildPaintingContent() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allows dynamic height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Walls & rooms Painting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10, // Adjust vertical spacing if needed
              alignment: WrapAlignment.center,
              children: [
                _buildServiceCard(
                    'assets/images/Bedroom.png', "Bedroom", () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Painting",
                              subcategory: "Bedroom",
                              imageUrl: 'assets/images/BedroomPainting.png',
                            )));
                    }),
                _buildServiceCard(
                    'assets/images/Hall.png', 'Living &\nDining room', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Painting",
                              subcategory: "Living & Dining room",
                              imageUrl: 'assets/images/LivingRoomPainting.png',
                            )));
                    }),
                _buildServiceCard(
                    'assets/images/Full_home.png', 'Full\nHome', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Painting",
                              subcategory: "Full Home",
                              imageUrl: 'assets/images/HomePainting.png',
                            )));
                    }),
                _buildServiceCard('assets/images/Kitchen&Bathroom.png',
                    'Kitchen\n& Bathroom', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Painting",
                              subcategory: "Kitchen & Bathroom",
                              imageUrl: 'assets/images/KitchenPainting.png',
                            )));
                    }),
                _buildServiceCard('assets/images/WaterProofing.png',
                    'Water\nProofing', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Painting",
                              subcategory: "Water Proofing",
                              imageUrl: 'assets/images/WaterProofingPainting.png',
                            )));
                    }),
              ],
            ),
          ],
        ));
  }

  Widget _buildCleaningContent() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allows dynamic height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cleaning & Pest Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10, // Adjust vertical spacing if needed
              alignment: WrapAlignment.center,
              children: [
                _buildServiceCard(
                    'assets/images/Bathroom.png', "Bathroom\nCleaning", () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Cleaning",
                              subcategory: "Bathroom Cleaning",
                              imageUrl: 'assets/images/BathroomCleaning.png',
                            )));
                    }),
                _buildServiceCard(
                    'assets/images/Kitchen.png', "Kitchen\nCleaning", () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Cleaning",
                              subcategory: "Kitchen Cleaning",
                              imageUrl: 'assets/images/KitchenCleaning.png',
                            )));
                    }),
                _buildServiceCard(
                    'assets/images/FullHome.png', 'Full\nHome Cleaning', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Cleaning",
                              subcategory: "Full Home Cleaning",
                              imageUrl: 'assets/images/HomeCleaning.png',
                            )));
                    }),
                _buildServiceCard('assets/images/Sofa&Carpet.png',
                    'Sofa &\nCarpet Cleaning', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Cleaning",
                              subcategory: "Sofa & Carpet Cleaning",
                              imageUrl: 'assets/images/CarpetCleaning.png',
                            )));
                    }),
                _buildServiceCard(
                    'assets/images/PestControl.png', 'Pest\nControl', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Cleaning",
                              subcategory: "Pest Control",
                              imageUrl: 'assets/images/PestControlImg.png',
                            )));
                    }),
              ],
            ),
          ],
        ));
  }

  Widget _buildPlumbingContent() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allows dynamic height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plumbing Works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10, // Adjust vertical spacing if needed
              alignment: WrapAlignment.center,
              children: [
                _buildServiceCard('assets/images/Leakage.png', "Blocks &\nLeakages", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Plumbing",
                              subcategory: "Blocks & Leakages",
                              imageUrl: 'assets/images/blocks&leakages.png',
                            )));
                }),
                _buildServiceCard('assets/images/BathFitting.png', "Bath\nFitting", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Plumbing",
                              subcategory: "Bath Fitting",
                              imageUrl: 'assets/images/BathFittingRepair.png',
                            )));
                }),
                _buildServiceCard('assets/images/Tap&Mixer.png', 'Tap &\nMixer', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Plumbing",
                              subcategory: "Tap & Mixer",
                              imageUrl: 'assets/images/TapRepair.png',
                            )));
                }),
                _buildServiceCard('assets/images/BasinSink.png', "Basin &\nSink", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Plumbing",
                              subcategory: "Basin & Sink",
                              imageUrl: 'assets/images/BasinSinkRepair.png',
                            )));
                }),
              ],
            ),
            SizedBox(height: 20),
          ],
        ));
  }


  Widget _buildElectricalContent() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allows dynamic height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Electrical Works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10, // Adjust vertical spacing if needed
              alignment: WrapAlignment.center,
              children: [
                _buildServiceCard('assets/images/Switch.png',
                    "Switch\nRepair & Services", () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Electrical",
                              subcategory: "Switch Repair & Services",
                              imageUrl: 'assets/images/SwitchRepair.png',
                            )));
                    }),
                _buildServiceCard('assets/images/Light.png',
                    "Lights\nRepair & Services", () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Electrical",
                              subcategory: "Lights Repair & Services",
                              imageUrl: 'assets/images/LightsRepair.png',
                            )));
                    }),
                _buildServiceCard(
                    'assets/images/Fan.png', 'Fan\nRepair & Services', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Electrical",
                              subcategory: "Fan Repair & Services",
                              imageUrl: 'assets/images/FanRepair.png',
                            )));
                    }),
                _buildServiceCard('assets/images/HomeDecoration.png',
                    'Festive\nLights\nDecoration', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Electrical",
                              subcategory: "Festive Lights Decoration",
                              imageUrl: 'assets/images/Decoration.png',
                            )));
                    }),
              ],
            ),
          ],
        ));
  }

  Widget _buildWomenSalonContent() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allows dynamic height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Women\'s Salon and Spa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10, // Adjust vertical spacing if needed
              alignment: WrapAlignment.center,
              children: [
                _buildServiceCard('assets/images/Salon.png', "Hair\nSalon", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Women's Salon & Spa",
                              subcategory: "Hair Salon",
                              imageUrl: 'assets/images/HairSalon.png',
                            )));
                }),
                _buildServiceCard('assets/images/ManicurePedicure.png',
                    "Manicure &\nPedicure", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Women's Salon & Spa",
                              subcategory: "Manicure & Pedicure",
                              imageUrl: 'assets/images/manicure&pedicure.png',
                            )));
                }),
                _buildServiceCard(
                    'assets/images/Spa.png', 'Spa &\nMassage', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Women's Salon & Spa",
                              subcategory: "Spa & Massage",
                              imageUrl: 'assets/images/Spa&Massage.png',
                            )));
                    }),
                _buildServiceCard(
                    'assets/images/Makeup.png', 'Makeup &\nStyling', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Women's Salon & Spa",
                              subcategory: "Makeup & Styling",
                              imageUrl: 'assets/images/Makeup&Styling.png',
                            )));
                    }),
              ],
            ),
          ],
        ));
  }

  Widget _buildMenSalonContent() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allows dynamic height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Men\'s Salon and Spa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10, // Adjust vertical spacing if needed
              alignment: WrapAlignment.center,
              children: [
                _buildServiceCard(
                    'assets/images/MenSalon.png', "Hair\nSalon", () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Men's Salon & Spa",
                              subcategory: "Hair Salon",
                              imageUrl: 'assets/images/HairTrim.png',
                            )));
                    }),
                _buildServiceCard(
                    'assets/images/MenSpa.png', "Spa &\nMassage", () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Men's Salon & Spa",
                              subcategory: "Spa & Massage",
                              imageUrl: 'assets/images/MenMassage.png',
                            )));
                    }),
                _buildServiceCard('assets/images/MenShaving.png',
                    'Beard Shave & \nTrim', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Men's Salon & Spa",
                              subcategory: "Beard Shave & Trim",
                              imageUrl: 'assets/images/BeardTrim.png',
                            )));
                    }),
                _buildServiceCard(
                    'assets/images/MenFacial.jpg', 'Facial', () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Men's Salon & Spa",
                              subcategory: "Facial",
                              imageUrl: 'assets/images/MenFacial.png',
                            )));
                    }),
              ],
            ),
          ],
        ));
  }

  Widget _buildCarpentaryWorksContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Allows dynamic height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carpentry',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 10, // Adjust spacing as needed
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildServiceCard('assets/images/Carpentary_repair.png',
                  "Door", () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Carpentary",
                              subcategory: "Door",
                              imageUrl: 'assets/images/DoorRepair.png',
                            )));
                  }),
              _buildServiceCard('assets/images/FurnitureAssembly.png',
                  "Furniture\nRepair", () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Carpentry",
                              subcategory: "Furniture Repair",
                              imageUrl: 'assets/images/Carpentary.png',
                            )));
                  }),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAppliancesRepairContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Allows dynamic height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appliances',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 10, // Adjust spacing as needed
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildServiceCard('assets/images/AC.png', "Air\nConditioner", () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Air Conditioner",
                              imageUrl: 'assets/images/AC_repair.png',
                            )));
              }),
              _buildServiceCard('assets/images/Chimney.png', "Chimney", () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Chimney",
                              imageUrl: 'assets/images/ChimneyRepair.png',
                            )));
              }),
              _buildServiceCard(
                  'assets/images/GasStove.png', 'Gas\nStove', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Gas Stove",
                              imageUrl: 'assets/images/StoveRepair.png',
                            )));
                  }),
              _buildServiceCard('assets/images/Geyser.png', 'Geyser', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Geyser",
                              imageUrl: 'assets/images/GeyserRepair.png',
                            )));
              }),
              _buildServiceCard(
                  'assets/images/Invertor.png', 'Inverter', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Inverter",
                              imageUrl: 'assets/images/InvertorRepair.png',
                            )));    
                  }),
              _buildServiceCard('assets/images/Laptop.png', 'Laptop', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Laptop",
                              imageUrl: 'assets/images/LaptopRepair.png',
                            )));
              }),
              _buildServiceCard(
                  'assets/images/WaterPurifier.png', 'Water\nPurifier', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Water Purifier",
                              imageUrl: 'assets/images/WaterPurifierRepair.png',
                            )));
                  }),
              _buildServiceCard('assets/images/WashingMachine.png',
                  'Washing\nMachine', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Washing Machine",
                              imageUrl: 'assets/images/WashingMachineRepair.png',
                            )));
                  }),
              _buildServiceCard(
                  'assets/images/Microwave.png', 'Microwave', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Microwave",
                              imageUrl: 'assets/images/MicrowaveRepair.png',
                            )));
                  }),
              _buildServiceCard(
                  'assets/images/Refridgerator.png', 'Refridgerator', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Refridgerator",
                              imageUrl: 'assets/images/FridgeRepair.png',
                            )));
                  }),
              _buildServiceCard('assets/images/TV.png', 'Television', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServicePage(
                              category: "Appliances",
                              subcategory: "Television",
                              imageUrl: 'assets/images/TVRepair.png',
                            )));
              }),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      String imagePath, String text, void Function() Navigate) {
    return GestureDetector(
      onTap: Navigate,
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8), // Slightly rounded corners
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  8), // Ensure the image follows the card's shape
              child: Image.asset(
                imagePath,
                width: 50, // Adjust width based on your design
                height: 50, // Keep it square
                fit: BoxFit.cover, // Ensures the image scales properly
              ),
            ),
          ),
          SizedBox(height: 4), // Spacing between card and text
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
