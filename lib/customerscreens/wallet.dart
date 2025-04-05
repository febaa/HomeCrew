import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homecrew/auth/auth_service.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final supabase = Supabase.instance.client;

  double walletBalance = 0.0;
  String customerName = "";
  String cardNumber = "**** **** **** 5678";
  String expiryDate = "12/26";
  int rewardPoints = 0;
  bool isLoading = true;
  late String uid;
  final authService = AuthService();

  @override
  void initState() {
    initPayment();
    super.initState();
    uid = authService.getCurrentUserId()!;
    fetchWalletAndUserDetails();
  }

  Future<void> fetchWalletAndUserDetails() async {
    setState(() => isLoading = true);
    try {

      // Fetch wallet data
      final walletResponse = await supabase
          .from('wallet')
          .select()
          .eq('user_id', uid)
          .single();

      walletBalance = walletResponse['balance']?.toDouble() ?? 0.0;
      rewardPoints = walletResponse['reward_points'] ?? 0;

      // Fetch user data
      final userResponse = await supabase
          .from('users')
          .select('name')
          .eq('uid', uid)
          .single();

      customerName = userResponse['name'] ?? "Customer";

    } catch (e) {
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load wallet details.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Wallet"),
        backgroundColor: const Color(0xFF006A4E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchWalletAndUserDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    _buildDebitCard(),
                    const SizedBox(height: 10),
                    _buildRewardSection(),
                    const SizedBox(height: 15),
                    const Text(
                      "🚀 Quick Actions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildGradientActionTile(
                          icon: Icons.add_circle,
                          label: "Add Money",
                          onTap: _addMoney,
                        ),
                        _buildGradientActionTile(
                          icon: Icons.history,
                          label: "Transactions",
                          onTap: _viewTransactions,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRewardSection() {
  bool hasCollectedCoupon = rewardPoints >= 100;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "🎁 Reward Points",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF006A4E),
        ),
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF006A4E), Color(0xFF00A86B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Text(
                  hasCollectedCoupon ? "Coupon Collected" : "$rewardPoints pts",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              "Progress Towards ₹50 Cashback",
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: rewardPoints / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: Colors.white,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasCollectedCoupon
                  ? "0 pts to go!"
                  : "${100 - rewardPoints} pts to go!",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


  Widget _buildDebitCard() {
    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF006A4E), Color(0xFF00A86B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              "Wallet Balance",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              "₹ ${walletBalance.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardDetail("Card Holder", customerName),
                _buildCardDetail("Expires", expiryDate),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cardNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white60,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGradientActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF006A4E), Color(0xFF00A86B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }







  void _addMoney() {
  showDialog(
    context: context,
    builder: (context) {
      final TextEditingController _amountController = TextEditingController();

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF006A4E), Color(0xFF00A86B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 50),
              const SizedBox(height: 12),
              const Text(
                "Add Money to Wallet",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.currency_rupee, color: Colors.grey),
                    hintText: "Enter amount",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
  String amount = _amountController.text.trim();
  String cleanedAmount = amount.replaceAll(RegExp(r'[^0-9.]'), '');
  
  if (cleanedAmount.isEmpty) return;

  double parsedAmount = double.tryParse(cleanedAmount) ?? 0;

  if (parsedAmount < 200) {
    Fluttertoast.showToast(msg: "Amount should be atleast 200 or more");
    return;
  }

  Navigator.pop(context);

  int intAmount = parsedAmount.toInt();
  body = getChecksum(intAmount).toString();
  startTransaction(parsedAmount);
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF006A4E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("Add"),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


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
    double amount,
  ) {
    PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName)
        .then((response) => {
              setState(() async {
                if (response != null) {
                  String status = response['status'].toString();
                  String error = response['error'].toString();
                  if (status == 'SUCCESS') {
                    result = "Flow Completed - Status: Success!";

                    await checkStatus(amount);
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
      double amount) async {
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
      
      await supabase.from('wallet').update({'balance': amount}).eq('user_id', uid);

      try {
        setState(() {
          _isCheckingOut = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Wallet(),
          ),
        );

        Fluttertoast.showToast(msg: "Money added to wallet");
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








  void _viewTransactions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Transactions"),
        content: const Text("Transaction history goes here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }
}
