import 'package:flutter/material.dart';

class OrderHelpScreen extends StatelessWidget {
  const OrderHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Help')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(
              leading: Icon(Icons.support_agent_outlined),
              title: Text('Chat with Support'),
              subtitle: Text('Available 24/7'),
            ),
            ListTile(
              leading: Icon(Icons.local_shipping_outlined),
              title: Text('Track Delivery'),
              subtitle: Text('Order progress and courier updates'),
            ),
            ListTile(
              leading: Icon(Icons.keyboard_return_outlined),
              title: Text('Manage Return'),
              subtitle: Text('Create or check return status'),
            ),
          ],
        ),
      ),
    );
  }
}
