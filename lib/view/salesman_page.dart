import 'package:flutter/material.dart';

class SalesmanPage extends StatelessWidget {
  const SalesmanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/salesman.gif',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),

            SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
