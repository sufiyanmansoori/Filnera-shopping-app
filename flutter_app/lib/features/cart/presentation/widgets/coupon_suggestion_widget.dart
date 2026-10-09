import 'package:flutter/material.dart';

import '../../data/models/coupon_model.dart';

class CouponSuggestionWidget extends StatelessWidget {
  const CouponSuggestionWidget({super.key, required this.coupon});

  final CouponModel coupon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_offer_outlined),
        title: Text(coupon.code),
        subtitle: Text(coupon.description),
        trailing: FilledButton.tonal(
          onPressed: () {},
          child: const Text('Apply'),
        ),
      ),
    );
  }
}
