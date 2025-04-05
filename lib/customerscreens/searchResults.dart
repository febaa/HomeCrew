import 'package:flutter/material.dart';
import 'package:homecrew/customerscreens/service_pages/servicePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> matchedServices = [];
  bool isLoading = true;

  final Color themeColor = const Color(0xFF006A4E);
  final Color listTileColor = const Color.fromARGB(255, 227, 252, 238);

  @override
  void initState() {
    super.initState();
    searchServices();
  }

  Future<void> searchServices() async {
    final queryWords = widget.query.toLowerCase().split(' ');

    final response = await supabase.from('services').select();

    if (response.isEmpty) {
      setState(() {
        matchedServices = [];
        isLoading = false;
      });
      return;
    }

    final services = List<Map<String, dynamic>>.from(response);

    final filtered = services.where((service) {
      final name = (service['name'] ?? '').toString().toLowerCase();
      final subcategory =
          (service['subcategory'] ?? '').toString().toLowerCase();

      return queryWords.any((word) =>
          name.contains(word) || subcategory.contains(word));
    }).toList();

    setState(() {
      matchedServices = filtered;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text(
          'Search Results',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: isLoading
    ? Center(child: CircularProgressIndicator(color: themeColor))
    : matchedServices.isEmpty
        ? Center(
            child: Text(
              'No matching services found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          )
        : Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 240, 240, 240),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${matchedServices.length} result${matchedServices.length == 1 ? '' : 's'} found',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: matchedServices.length,
                    itemBuilder: (context, index) {
                      final service = matchedServices[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            final String subcategory = service['subcategory'];
                            final String category = service['category']; // assuming this field exists
                            final String imageUrl = 'assets/images/${subcategory.trim().replaceAll(' ', '')}.png';

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServicePage(
                                  category: category,
                                  subcategory: subcategory,
                                  imageUrl: imageUrl,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14, top: 5),
                            decoration: BoxDecoration(
                              color: listTileColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              leading: Icon(Icons.miscellaneous_services,
                                  color: themeColor),
                              title: Text(
                                "${service['subcategory']} - ${service['name']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios_rounded,
                                  size: 18, color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
