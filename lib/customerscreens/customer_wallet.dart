import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerWallet extends StatelessWidget {
  const CustomerWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          Text("CUSTOMER WALLET"),
          ElevatedButton(
              onPressed: () async {
                
              },
              child: Text("INSERT ROW"))
        ],
      ),
    ));
  }
}
