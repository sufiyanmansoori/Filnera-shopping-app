import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/saved_payment_card.dart';

class SavedCardsScreen extends StatelessWidget {
  const SavedCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        'title': 'Aisha Rahman',
        'brand': 'VISA',
        'lastFour': '2044',
        'expiry': '07/29',
      },
      {
        'title': 'Aisha Rahman',
        'brand': 'MASTERCARD',
        'lastFour': '0134',
        'expiry': '10/28',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Saved cards')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: ListView(
            children: [
              const Text(
                'Manage your cards',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              ...cards.map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SavedPaymentCard(
                    title: card['title'] as String,
                    brand: card['brand'] as String,
                    lastFour: card['lastFour'] as String,
                    expiry: card['expiry'] as String,
                    isPrimary: card['brand'] == 'VISA',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${card['brand']} card selected')),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add new card flow coming soon.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_card_rounded),
                  label: const Text('Add new card'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
