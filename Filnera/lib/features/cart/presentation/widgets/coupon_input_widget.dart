import 'package:flutter/material.dart';

class CouponInputWidget extends StatelessWidget {
  const CouponInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Coupon code',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(onPressed: () {}, child: const Text('Apply')),
          ],
        ),
      ),
    );
  }
}
