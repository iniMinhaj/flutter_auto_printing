import 'package:flutter/material.dart';

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/kitchen.gif', width: 200, height: 200),
            SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
