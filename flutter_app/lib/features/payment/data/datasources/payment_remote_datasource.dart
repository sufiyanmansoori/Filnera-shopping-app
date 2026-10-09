class PaymentRemoteDatasource {
  const PaymentRemoteDatasource();

  Future<List<Map<String, dynamic>>> fetchPaymentMethods() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return [
      {
        'id': 'upi',
        'type': 'upi',
        'title': 'UPI',
        'subtitle': 'Pay instantly with your preferred UPI app',
        'icon': 'account_balance_wallet',
        'isRecommended': true,
        'isEnabled': true,
        'metadata': {'provider': 'PhonePe, GPay, Paytm'},
      },
      {
        'id': 'card',
        'type': 'card',
        'title': 'Card',
        'subtitle': 'Credit or debit card with secure checkout',
        'icon': 'credit_card',
        'isRecommended': false,
        'isEnabled': true,
        'metadata': {'network': 'Visa, MasterCard, RuPay'},
      },
      {
        'id': 'wallet',
        'type': 'wallet',
        'title': 'Wallet',
        'subtitle': 'Use stored wallet balance or cashbacks',
        'icon': 'wallet',
        'isRecommended': false,
        'isEnabled': true,
        'metadata': {'provider': 'Paytm, Amazon Pay'},
      },
      {
        'id': 'cod',
        'type': 'cod',
        'title': 'Cash on Delivery',
        'subtitle': 'Pay when your order arrives at your doorstep',
        'icon': 'local_shipping',
        'isRecommended': false,
        'isEnabled': true,
        'metadata': {'fee': 49.0},
      },
    ];
  }
}
