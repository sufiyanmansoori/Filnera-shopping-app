import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiPaymentService {
  UpiPaymentService._();

  static final UpiPaymentService instance = UpiPaymentService._();

  static const String merchantUpiId = 'business@upi.example';
  static const String merchantName = 'Filnera Store';

  String buildUpiLink({required String orderId, required double amount}) {
    final cleanOrderId = orderId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');
    final amountText = amount.toStringAsFixed(2);
    return 'upi://pay?pa=$merchantUpiId&pn=$merchantName&am=$amountText&cu=INR&tn=$cleanOrderId';
  }

  Future<bool> launchUpiIntent({
    required String orderId,
    required double amount,
  }) async {
    final link = buildUpiLink(orderId: orderId, amount: amount);

    final uri = Uri.parse(link);
    if (!await canLaunchUrl(uri)) {
      return false;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    return launched;
  }

  Widget buildQrFallback({required String orderId, required double amount}) {
    final link = buildUpiLink(orderId: orderId, amount: amount);
    return Center(
      child: SizedBox(
        width: 260,
        height: 260,
        child: QrImageView(
          data: link,
          version: QrVersions.auto,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}
