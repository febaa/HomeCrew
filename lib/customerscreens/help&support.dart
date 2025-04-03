import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  // Function to open phone dialer
  void _launchPhone() async {
    final Uri url = Uri.parse("tel:+918367700230");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // Function to open WhatsApp chat
  void _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/918367700230");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // Function to open email client
  void _launchEmail() async {
    final Uri url = Uri.parse("mailto:help@homecrew.in");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Us",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF006A4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildContactCard(
              icon: FontAwesomeIcons.phone,
              title: "Phone",
              subtitle: "+91 8367700230",
              onTap: _launchPhone,
            ),
            _buildContactCard(
              icon: FontAwesomeIcons.whatsapp,
              title: "WhatsApp",
              subtitle: "+91 8367700230",
              onTap: _launchWhatsApp,
            ),
            _buildContactCard(
              icon: FontAwesomeIcons.envelope,
              title: "Email",
              subtitle: "help@homecrew.in",
              onTap: _launchEmail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      ),
    );
  }
}
