import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Homecrew",style: TextStyle(color: Colors.white), ),
        backgroundColor: const Color(0xFF006A4E), // Green theme 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),
              const Text(
                "Verified, certified and professional home services experts to make your life simpler than ever before.\n\n"
                "Homecrew is one of the most trusted, reliable, affordable best Home Services App and Maintenance platforms to get all your basic needs and local Home Services right at your doorstep.\n\n"
                "All you have to do is, just order, sit back and relax. At Homecrew you can book a range of home services, home repairs & home maintenance from an electrician to plumber to painter to carpenter to cleaning and much more right from the comfort of your home with just a few clicks.\n\n"
                "Our Mission is to empower millions of service professionals by delivering services at-home in a way that has never been experienced before.\n\n"
                "The complete list of services at Homecrew includes appliance repairs, home services, household works, beauty & wellness, salon services, and home maintenance.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5, // Improves readability
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Our Services Include:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "- Home Services, Appliance Repairs & Maintenance: Plumbers, Electricians, Painters, AC Repair, etc.\n"
                "- Home Renovation: House Painting, Bathroom Renovation, etc.\n"
                "- Health, Wellness & Beauty: Beauticians, Salon Services, etc.\n"
                "- Other Services: Home Cleaning, Pest Control, Events, etc.\n\n",
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              
              const Text(
                "Why Choose Homecrew?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "1. Trusted, reliable, and affordable\n"
                "2. Easy online booking\n"
                "3. Services delivered at your doorstep\n"
                "4. On-demand and on-time\n"
                "5. Certified and verified professionals\n"
                "6. Hassle-free experience\n"
                "7. 24/7 customer service\n"
                "8. 100% customer satisfaction guaranteed\n\n",
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              
              const Text(
                "Homecrew Availability",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Currently, we operate in Mumbai. We are expanding to Bengaluru, Mumbai, Delhi, Noida, Chennai, Gurgaon, Faridabad, and international locations including UAE, UK, Singapore, London, Toronto, Australia, and Canada.\n\n",
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              
              const Text(
                "Contact Us",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "For complaints or suggestions, please email us at:\n",
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const Text(
                "help.homecrew@gmail.com\n",
                style: TextStyle(fontSize: 16, color: Colors.blue, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
