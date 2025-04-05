import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OffersCouponsPage extends StatefulWidget {
  @override
  State<OffersCouponsPage> createState() => _OffersCouponsPageState();
}

class _OffersCouponsPageState extends State<OffersCouponsPage> {
  List<Map<String, dynamic>> _coupons = [];
  bool isLoading = true;
  final supabase = Supabase.instance.client;
  late String uid;
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    uid = authService.getCurrentUserId()!;
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('coupons')
          .select()
          .eq('user_id', uid)
          .order('validity', ascending: true);

      setState(() {
        _coupons = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching coupons: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF006A4E),
        title: Text(
          'Offers & Coupons',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : _coupons.isEmpty
              ? Center(
                  child: Text(
                    "No coupons found",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchCoupons,
                  color: Colors.green,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = _coupons[index];
                      final formattedDate = DateFormat('dd-MM-yyyy').format(
                        DateTime.parse(coupon['validity']),
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green.shade700, width: 2),
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.green.shade50,
                                  padding: EdgeInsets.all(12),
                                  width: double.infinity,
                                  child: Text(
                                    coupon['name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade400,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              coupon['detail'],
                                              style: GoogleFonts.poppins(fontSize: 14),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              "Valid till: $formattedDate",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          children: [
                                            Text(
                                              "Promo Code",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(height: 5),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 12),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(6),
                                                color: Colors.green.shade100,
                                                border: Border.all(color: Colors.green),
                                              ),
                                              child: Text(
                                                coupon['promocode'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: List.generate(
                                      60,
                                      (index) => Expanded(
                                        child: Container(
                                          height: 1,
                                          color: index % 2 == 0
                                              ? Colors.transparent
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
