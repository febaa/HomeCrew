import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customerscreens/phonepe.dart';
import 'package:homecrew/customerscreens/successPage.dart';
import 'package:homecrew/customerscreens/thankyou.dart';
import 'package:homecrew/customerscreens/thankyoucomplete.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class OffersPage extends StatefulWidget {
  final int bookingId;

  const OffersPage({Key? key, required this.bookingId}) : super(key: key);

  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> offers = [];
  late String uid;
  final authService = AuthService();

  late double currentAmount;
  final TextEditingController _negotiateController = TextEditingController();

  bool _isCheckingOut = false;
  String environmentValue = "SANDBOX";
  String appId = "";
  String merchantId = "PGTESTPAYUAT86";
  bool enableLogging = true;
  String transactionId = DateTime.now().millisecondsSinceEpoch.toString();

  String saltKey = "96434309-7796-489d-8924-ab56988a6076";
  String saltIndex = "1";

  String body = "";
  String callback = "https://webhook.site/14d3b80d-ab28-4c01-afdb-8d84e459eaba";
  String checksum = "";
  String packageName = "";
  String apiEndPoint = "/pg/v1/pay";

  Object? result;

  @override
  void initState() {
    initPayment();
    super.initState();
    uid = authService.getCurrentUserId()!;
    fetchOffers();
  }

  void initPayment() {
    PhonePePaymentSdk.init(environmentValue, appId, merchantId, enableLogging)
        .then((val) => {
              setState(() {
                result = 'PhonePe SDK Initialized - $val';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void handleError(error) {
    result = error;
  }

  void startTransaction(int bookingId, double amount, String spId) {
    PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName)
        .then((response) => {
              setState(() async {
                if (response != null) {
                  String status = response['status'].toString();
                  String error = response['error'].toString();
                  if (status == 'SUCCESS') {
                    result = "Flow Completed - Status: Success!";

                    await checkStatus(bookingId, amount, spId);
                  } else {
                    result =
                        "Flow Completed - Status: $status and Error: $error";
                  }
                } else {
                  result = "Flow Incomplete";
                }
              })
            })
        .catchError((error) {
      // handleError(error)
      return <dynamic>{};
    });
  }

  checkStatus(int bookingId, double amount, String spId) async {
    setState(() {
      _isCheckingOut = true;
    });
    String url =
        "https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/status/$merchantId/$transactionId";

    String concatString = "/pg/v1/status/$merchantId/$transactionId$saltKey";

    var bytes = utf8.encode(concatString);

    var digest = sha256.convert(bytes).toString();

    String xVerify = "$digest###$saltIndex";

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-VERIFY": xVerify,
      "X-MERCHANT-ID": merchantId
    };

    await http.get(Uri.parse(url), headers: headers).then((value) async {
      Map<String, dynamic> res = jsonDecode(value.body);

      if (res["success"] &&
          res["code"] == "PAYMENT_SUCCESS" &&
          res['data']['state'] == "COMPLETED") {
        Fluttertoast.showToast(msg: res["message"]);

        // 1. Update bookings and delete offers
        await supabase.from('bookings').update({
          'status': 'completed',
          'asking_price': amount,
          'service_provider_id': spId
        }).eq('id', bookingId);

        await supabase.from('offers').delete().eq('booking_id', bookingId);

        // 2. Calculate 5% reward points
        int rewardPoints = (amount * 0.05).round();

        // 3. Fetch current reward points from the wallet
        final walletRes = await supabase
            .from('wallet')
            .select('reward_points, id')
            .eq('user_id', uid)
            .single(); // since only one row exists per user

        int existingPoints = walletRes['reward_points'] ?? 0;
        int updatedPoints = existingPoints + rewardPoints;

        // 4. Update the wallet table with new reward points
        await supabase
            .from('wallet')
            .update({'reward_points': updatedPoints}).eq('id', walletRes['id']);

        // 5. If reward points >= 100, insert a ₹50 coupon
        if (updatedPoints >= 100) {
          await supabase.from('coupons').insert({
            'name': "Collected 100 Reward Points",
            'promocode': "FLAT50OFF",
            'detail': "Get Flat ₹50 Off on your next order",
            'validity': DateTime.now().add(Duration(days: 7)).toIso8601String(),
            'user_id': uid,
            'discount_amount': 50
          });

        }

        await supabase.from('notifications').insert({
                                                        'user_id': spId,
                                                        'title': "Payment Completed by a Customer",
                                                        'subtitle': "Payment was completed by a customer of a service request that you accepted."
                                                      });

        // 6. Navigate to Thank You screen
        try {
          setState(() {
            _isCheckingOut = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThankYouComplete(),
            ),
          );
        } catch (e) {}
      } else {
        Fluttertoast.showToast(msg: "Something went wrong!");
      }
    });
  }

  getChecksum(int totalAmount) {
    final reqData = {
      "merchantId": merchantId,
      "merchantTransactionId": transactionId,
      "merchantUserId": "MUID123",
      "amount": totalAmount * 100,
      "callbackUrl": callback,
      "mobileNumber": "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };

    String base64body = base64.encode(utf8.encode(json.encode(reqData)));

    checksum =
        '${sha256.convert(utf8.encode(base64body + apiEndPoint + saltKey)).toString()}###$saltIndex';

    return base64body;
  }

  Future<void> fetchOffers() async {
    final response = await supabase
        .from('offers')
        .select('*, users(name, age, gender)')
        .eq('booking_id', widget.bookingId);

    if (response != null) {
      setState(() {
        offers = List<Map<String, dynamic>>.from(response);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Offers"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isCheckingOut ? Center(child: CircularProgressIndicator()) 
      : RefreshIndicator(
        onRefresh: fetchOffers,
        child: offers.isEmpty
            ? Center(
                child: Text(
                  "No offers received",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  final provider = offer['users'] ?? {}; // Get provider details
        
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.only(bottom: 16),
                    color: Color.fromARGB(255, 247, 247, 247),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Service Provider: ${provider['name'] ?? 'Unknown'}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF006A4E),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Age: ${provider['age'] ?? 'N/A'}",
                            style: TextStyle(color: Color(0xFF006A4E)),
                          ),
                          Text(
                            "Gender: ${provider['gender'] ?? 'N/A'}",
                            style: TextStyle(color: Color(0xFF006A4E)),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Asking Price: ₹${offer['asking_price']}",
                            style: TextStyle(color: Color(0xFF006A4E)),
                          ),
                          Text(
                            "Status: ${offer['accepted'] ? 'Accepted' : 'Pending'}",
                            style: TextStyle(
                              color: offer['accepted']
                                  ? Color(0xFF006A4E)
                                  : const Color.fromARGB(255, 183, 125, 37),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (offer['accepted'] == false &&
                              offer['negotiated'] == true) ...[
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.7, // Adjust width dynamically
                              child: Text(
                                "You have made a counter offer, please wait till the service provider responds.",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                                softWrap: true, // Allows text to wrap
                              ),
                            ),
                          ] else if (offer['accepted'] == false &&
                              offer['negotiated'] == false) ...[
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.7, // Adjust width dynamically
                              child: Text(
                                "You can either accept the offer or make a counter offer.",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                                softWrap: true, // Allows text to wrap
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ] else if (offer['accepted'] == true) ...[
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.7, // Adjust width dynamically
                              child: Text(
                                "You can either accept the offer or make a counter offer.",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                                softWrap: true, // Allows text to wrap
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
        
                          // Buttons Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (offer['accepted'] == false &&
                                  offer['negotiated'] == false) ...[
                                // Show Accept and Negotiate buttons only if not accepted
                                ElevatedButton(
                                  onPressed: () {
                                    showCouponDialog(
                                      offer['asking_price'],
                                      widget.bookingId,
                                      offer['service_provider_id'],
                                    );
                                  },
                                  child: Text(
                                    'Accept & Pay',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF006A4E),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (offer['offercount'] >= 4) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("Negotiation Limit Reached"),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return; // Stop execution if limit is reached
                                    }
        
                                    // Handle Negotiate Offer
                                    currentAmount = offer['asking_price'];
                                    _negotiateController.text =
                                        currentAmount.toStringAsFixed(2);
        
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                16), // Rounded corners
                                          ),
                                          elevation: 16,
                                          backgroundColor: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Title
                                                Text(
                                                  'Negotiate Price',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        const Color(0xFF006A4E),
                                                  ),
                                                ),
                                                SizedBox(height: 16),
        
                                                // Displaying the initial amount
                                                Text(
                                                  'Current Asking Price: ₹${offer['asking_price']}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 16),
        
                                                // Row with + and - buttons on the sides of the text field
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Decrease Button
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          currentAmount =
                                                              (currentAmount - 10)
                                                                  .clamp(
                                                                      0,
                                                                      offer['asking_price']
                                                                          as double)
                                                                  .toDouble();
                                                          _negotiateController
                                                                  .text =
                                                              currentAmount
                                                                  .toStringAsFixed(
                                                                      2);
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                              0xFF006A4E),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Icon(Icons.remove,
                                                            color: Colors.white,
                                                            size: 24),
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
        
                                                    // TextField for Negotiated Amount
                                                    Container(
                                                      width:
                                                          120, // Reduced width for the text field
                                                      child: TextField(
                                                        controller:
                                                            _negotiateController,
                                                        keyboardType:
                                                            TextInputType.number,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'Negotiated',
                                                          labelStyle: TextStyle(
                                                            color: const Color(
                                                                0xFF006A4E),
                                                          ),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          12),
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            currentAmount = double
                                                                    .tryParse(
                                                                        value) ??
                                                                0; // Update current amount
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
        
                                                    // Increase Button
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          currentAmount =
                                                              (currentAmount + 10)
                                                                  .clamp(
                                                                      0,
                                                                      offer['asking_price']
                                                                          as double)
                                                                  .toDouble();
                                                          _negotiateController
                                                                  .text =
                                                              currentAmount
                                                                  .toStringAsFixed(
                                                                      2);
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                              0xFF006A4E),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Icon(Icons.add,
                                                            color: Colors.white,
                                                            size: 24),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 16),
        
                                                // Display the updated negotiated amount
                                                Text(
                                                  'Negotiated Amount: ₹${currentAmount.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        const Color(0xFF006A4E),
                                                  ),
                                                ),
                                                SizedBox(height: 24),
        
                                                // Buttons at the bottom
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    // Cancel button
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context); // Close the dialog
                                                      },
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: Colors.grey[700],
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
        
                                                    // Confirm button
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await supabase
                                                            .from('bookings')
                                                            .update({
                                                          'asking_price':
                                                              currentAmount,
                                                          'SNegotiated': true,
                                                          'CNegotiated': false
                                                        }).eq(
                                                                'id',
                                                                offer[
                                                                    'booking_id']);
                                                        await supabase
                                                            .from('offers')
                                                            .update({
                                                          'asking_price':
                                                              currentAmount,
                                                          'negotiated': true
                                                        }).eq('id', offer['id']);
        
                                                        final offerId =
                                                            offer['id'];
        
                                                        // Step 1: Get current offercount
                                                        final response =
                                                            await supabase
                                                                .from('offers')
                                                                .select(
                                                                    'offercount')
                                                                .eq('id', offerId)
                                                                .single();
        
                                                        if (response != null &&
                                                            response[
                                                                    'offercount'] !=
                                                                null) {
                                                          final currentCount =
                                                              response[
                                                                      'offercount']
                                                                  as int;
        
                                                          // Step 2: Update the count
                                                          await supabase
                                                              .from('offers')
                                                              .update({
                                                            'offercount':
                                                                currentCount + 1
                                                          }).eq('id', offerId);
                                                        }
        
                                                        await supabase.from('notifications').insert({
                                                          'user_id': offer['service_provider_id'],
                                                          'title': "Offer Negotiated by Customer",
                                                          'subtitle': "Your offer was negotiated by a customer, please check your service requests."
                                                        });
        
                                                        fetchOffers();
        
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  "Price Increased Successfully")),
                                                        );
                                                      },
                                                      child: Text(
                                                        'Confirm',
                                                        style: TextStyle(
                                                            color: Colors.white),
                                                      ),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: const Color(
                                                            0xFF006A4E), // Button color
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 20,
                                                                vertical: 12),
                                                        textStyle: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Negotiate',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF006A4E),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ]
        
                              // Show "Accept and Pay" button only if offer is accepted
                              else if (offer['accepted'] == true) ...[
                                ElevatedButton(
                                  onPressed: () {
                                    showCouponDialog(
                                      offer['asking_price'],
                                      widget.bookingId,
                                      offer['service_provider_id'],
                                    );
                                  },
                                  child: Text(
                                    'Accept & Pay',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF006A4E),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ] else if (offer['accepted'] == false &&
                                  offer['negotiated'] == true)
                                ...[]
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

void showCouponDialog(double askingPrice, int bookingId, String serviceProviderId) {
  TextEditingController _couponController = TextEditingController();
  bool isChecking = false;
  String? errorText;
  bool couponApplied = false;
  double discountedPrice = askingPrice;
  String selectedPaymentMethod = 'Wallet';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE0F8EC), Color(0xFFC6F1DD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.discount, size: 48, color: Colors.green),
                    const SizedBox(height: 8),
                    Text("Apply Coupon",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text("Save more with a coupon or reward points",
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 20),

                    // Payment Method Toggle
                    Row(
                      children: ['Wallet', 'PhonePe'].map((method) {
                        final isSelected = selectedPaymentMethod == method;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedPaymentMethod = method),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green.shade700 : Colors.white,
                                border: Border.all(color: Colors.green.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  method,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Coupon Code Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          hintText: "Enter coupon code",
                          hintStyle: GoogleFonts.poppins(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (couponApplied)
                      Text("🎉 Coupon applied!", style: GoogleFonts.poppins(color: Colors.green.shade800)),
                    if (errorText != null)
                      Text(errorText!, style: GoogleFonts.poppins(color: Colors.red.shade800)),

                    const SizedBox(height: 15),

                    // Payable Amount
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Payable Amount:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                          Text("₹${discountedPrice.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey[700])),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isChecking
                                ? null
                                : () async {
                                    setState(() {
                                      isChecking = true;
                                      errorText = null;
                                      couponApplied = false;
                                    });

                                    final couponCode = _couponController.text.trim();

                                    if (couponCode.isEmpty) {
                                      setState(() {
                                        isChecking = false;
                                        errorText = "Please enter a coupon code.";
                                      });
                                      return;
                                    }

                                    final response = await Supabase.instance.client
                                        .from('coupons')
                                        .select()
                                        .eq('user_id', uid)
                                        .eq('promocode', couponCode)
                                        .limit(1);

                                    if (response.isEmpty) {
                                      setState(() {
                                        isChecking = false;
                                        errorText = "Invalid or expired coupon.";
                                      });
                                      return;
                                    }

                                    final coupon = response.first;
                                    final double discount = coupon['discount_amount']?.toDouble() ?? 0.0;
                                    discountedPrice = askingPrice - discount;

                                    await Supabase.instance.client
                                        .from('coupons')
                                        .delete()
                                        .eq('id', coupon['id']);

                                    setState(() {
                                      isChecking = false;
                                      couponApplied = true;
                                    });
                                  },
                            child: isChecking
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text("Apply Coupon",
                                    style: GoogleFonts.poppins(color: Colors.white, textStyle: TextStyle(fontSize: 13))),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                        if (selectedPaymentMethod == 'Wallet') {
                          await handleWalletPayment(bookingId, discountedPrice, serviceProviderId);
                        } else if (selectedPaymentMethod == 'PhonePe') {
                          Navigator.pop(context);
                          body = getChecksum(discountedPrice.toInt()).toString();
                          startTransaction(bookingId, discountedPrice, serviceProviderId);
                        }
                      },
                        label: Text(
                          "Pay with $selectedPaymentMethod",
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}






Future<void> handleWalletPayment(
    int bookingId, double amount, String spId) async {
  try {
    // 1. Fetch wallet info
    final walletRes = await Supabase.instance.client
        .from('wallet')
        .select('reward_points, id, balance')
        .eq('user_id', uid)
        .single();

    int existingPoints = walletRes['reward_points'] ?? 0;
    int walletBalance = walletRes['balance'] ?? 0;

    // 2. Check if wallet has enough balance
    if (walletBalance < amount) {
      Navigator.pop(context); // Close dialog
      Fluttertoast.showToast(msg: "Insufficient balance in wallet");
      return;
    }

    // 3. Deduct amount from wallet balance
    int updatedBalance = walletBalance - amount.toInt();

    await Supabase.instance.client
        .from('wallet')
        .update({'balance': updatedBalance}).eq('id', walletRes['id']);

    // 4. Update bookings and delete offers
    await Supabase.instance.client.from('bookings').update({
      'status': 'completed',
      'asking_price': amount,
      'service_provider_id': spId
    }).eq('id', bookingId);

    await Supabase.instance.client
        .from('offers')
        .delete()
        .eq('booking_id', bookingId);

    // 5. Calculate reward points
    int rewardPoints = (amount * 0.05).round();
    int updatedPoints = existingPoints + rewardPoints;

    await Supabase.instance.client
        .from('wallet')
        .update({'reward_points': updatedPoints}).eq('id', walletRes['id']);

    // 6. Give coupon if points >= 100
    if (updatedPoints >= 100) {
      await Supabase.instance.client.from('coupons').insert({
        'name': "Collected 100 Reward Points",
        'promocode': "FLAT50OFF",
        'detail': "Get Flat ₹50 Off on your next order",
        'validity': DateTime.now().add(Duration(days: 7)),
        'user_id': uid,
        'discount_amount': 50
      });

      await Supabase.instance.client
          .from('wallet')
          .update({'reward_points': 0}).eq('id', walletRes['id']);
    }

    await supabase.from('notifications').insert({
                                                        'user_id': spId,
                                                        'title': "Payment Completed by a Customer",
                                                        'subtitle': "Payment was completed by a customer of a service request that you accepted."
                                                      });

    // 7. Navigate to Thank You screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ThankYouComplete()),
    );
  } catch (e) {
    print("Wallet Payment Error: $e");
    Fluttertoast.showToast(msg: "Something went wrong!");
  }
}


}
