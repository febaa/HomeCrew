import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  void startTransaction(
    int bookingId,
    double amount
  ) {
    PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName)
        .then((response) => {
              setState(() async {
                if (response != null) {
                  String status = response['status'].toString();
                  String error = response['error'].toString();
                  if (status == 'SUCCESS') {
                    result = "Flow Completed - Status: Success!";

                    await checkStatus(bookingId, amount);
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

  checkStatus(
      int bookingId, double amount) async {
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

        await supabase.from('bookings').update({'status': 'completed','asking_price': amount}).eq('id', bookingId);
        await supabase.from('offers').delete().eq('booking_id', bookingId);

        try {
          setState(() {
            _isCheckingOut = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThankYouComplete(), // Pass document ID to SellerHomeScreen
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
      body: offers.isEmpty
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
                        SizedBox(height: 10,),
                        if(offer['accepted']==false && offer['negotiated']==true)...[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7, // Adjust width dynamically
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
                      ] else if(offer['accepted']==false && offer['negotiated']==false)...[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7, // Adjust width dynamically
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
                        SizedBox(height: 10,)
                      ] else if(offer['accepted']==true)...[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7, // Adjust width dynamically
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
                        SizedBox(height: 10,)
                      ],

                        // Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (offer['accepted']==false && offer['negotiated']==false)...[ // Show Accept and Negotiate buttons only if not accepted
                              ElevatedButton(
                                onPressed: () {
                                  // Handle Accept Offer
                                  body = getChecksum(offer['asking_price'].toInt())
                                      .toString();
                                  startTransaction(widget.bookingId, offer['asking_price']);
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
                              SizedBox(width: 10,),
                              ElevatedButton(
                                onPressed: () async {
                                  

                                  if (offer['offercount'] >= 4) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Negotiation Limit Reached"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return; // Stop execution if limit is reached
                                  }


                                // Handle Negotiate Offer
                                currentAmount = offer['asking_price'];
                                _negotiateController.text = currentAmount.toStringAsFixed(2);

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16), // Rounded corners
                                      ),
                                      elevation: 16,
                                      backgroundColor: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Title
                                            Text(
                                              'Negotiate Price',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF006A4E),
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
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // Decrease Button
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      currentAmount = (currentAmount - 10).clamp(0, offer['asking_price'] as double).toDouble();
                                                      _negotiateController.text = currentAmount.toStringAsFixed(2);
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF006A4E),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(Icons.remove, color: Colors.white, size: 24),
                                                  ),
                                                ),
                                                SizedBox(width: 16),

                                                // TextField for Negotiated Amount
                                                Container(
                                                  width: 120, // Reduced width for the text field
                                                  child: TextField(
                                                    controller: _negotiateController,
                                                    keyboardType: TextInputType.number,
                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                    decoration: InputDecoration(
                                                      labelText: 'Negotiated',
                                                      labelStyle: TextStyle(color: const Color(0xFF006A4E),),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        currentAmount = double.tryParse(value) ?? 0; // Update current amount
                                                      });
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 16),

                                                // Increase Button
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      currentAmount = (currentAmount + 10).clamp(0, offer['asking_price'] as double).toDouble();
                                                      _negotiateController.text = currentAmount.toStringAsFixed(2);
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF006A4E),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(Icons.add, color: Colors.white, size: 24),
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
                                                color: const Color(0xFF006A4E),
                                              ),
                                            ),
                                            SizedBox(height: 24),

                                            // Buttons at the bottom
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                // Cancel button
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context); // Close the dialog
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
                                                        await supabase.from('bookings').update({'asking_price': currentAmount, 'SNegotiated': true, 'CNegotiated': false}).eq('id', offer['booking_id']);
                                                        await supabase.from('offers').update({'asking_price': currentAmount, 'negotiated': true}).eq('id', offer['id']);
                                                        await supabase.from('offers').update({
                                                          'offercount': supabase.from('offers').select('offercount').eq('id', offer['id']).single().then((res) => res['offercount'] + 1)
                                                        }).eq('id', offer['id']);
                                                        
                                                        fetchOffers();
                                                        
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text("Price Increased Successfully")),
                                                        );
                                                      },
                                                  child: Text('Confirm',style: TextStyle(color: Colors.white),),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF006A4E), // Button color
                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                    textStyle: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
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
                            else if (offer['accepted']==true)...[
                              ElevatedButton(
                                onPressed: () {
                                  body = getChecksum(offer['asking_price'].toInt())
                                      .toString();
                                  startTransaction(widget.bookingId, offer['asking_price']);
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
                            ]
                            else if(offer['accepted']==false && offer['negotiated']==true)...[
                              
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
