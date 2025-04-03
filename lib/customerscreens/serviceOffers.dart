import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:homecrew/customerscreens/phonepe.dart';
import 'package:homecrew/customerscreens/successPage.dart';
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
  ) {
    PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName)
        .then((response) => {
              setState(() async {
                if (response != null) {
                  String status = response['status'].toString();
                  String error = response['error'].toString();
                  if (status == 'SUCCESS') {
                    result = "Flow Completed - Status: Success!";

                    await checkStatus(bookingId);
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
      int bookingId) async {
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

        try {
          setState(() {
            _isCheckingOut = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessPage(), // Pass document ID to SellerHomeScreen
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
                            color: Color(0xFF388E3C),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Age: ${provider['age'] ?? 'N/A'}",
                          style: TextStyle(color: Color(0xFF388E3C)),
                        ),
                        Text(
                          "Gender: ${provider['gender'] ?? 'N/A'}",
                          style: TextStyle(color: Color(0xFF388E3C)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Asking Price: ₹${offer['asking_price']}",
                          style: TextStyle(color: Color(0xFF388E3C)),
                        ),
                        Text(
                          "Status: ${offer['accepted'] ? 'Accepted' : 'Pending'}",
                          style: TextStyle(
                            color: offer['accepted']
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (!offer[
                                'accepted']) // Show Accept and Negotiate buttons only if not accepted
                              ...[
                              ElevatedButton(
                                onPressed: () {
                                  // Handle Accept Offer
                                },
                                child: Text(
                                  'Accept',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF388E3C),
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
                              ElevatedButton(
                                onPressed: () {
                                  // Handle Negotiate Offer
                                },
                                child: Text(
                                  'Negotiate',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
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
                            ],

                            // Show "Accept and Pay" button only if offer is accepted
                            if (offer['accepted'])
                              ElevatedButton(
                                onPressed: () {
                                  body = getChecksum(offer['asking_price'].toInt())
                                      .toString();
                                  startTransaction(widget.bookingId);
                                },
                                child: Text(
                                  'Accept and Pay',
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
