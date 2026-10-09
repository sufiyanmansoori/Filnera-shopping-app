import 'package:flutter/material.dart';

import '../../data/models/coupon_model.dart';
import '../widgets/coupon_input_widget.dart';
import '../widgets/coupon_suggestion_widget.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key, required this.coupons});

  final List<CouponModel> coupons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply Coupon')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const CouponInputWidget(),
            const SizedBox(height: 16),
            ...coupons.map((coupon) => CouponSuggestionWidget(coupon: coupon)),
          ],
        ),
      ),
    );
  }
}
