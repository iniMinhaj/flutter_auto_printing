import 'package:flutter/material.dart';

class PaymentSuccess extends StatefulWidget {
  const PaymentSuccess({super.key});

  @override
  State<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  // initPrinter() async {
  //   await connectAndPrint(modelName: 'PT-210');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Payment Successful")));
  }
}
