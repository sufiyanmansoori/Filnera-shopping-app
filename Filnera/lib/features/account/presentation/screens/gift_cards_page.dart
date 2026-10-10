import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Gift cards, wallet and saved payment methods page.
///
/// IMPORTANT:
/// This UI does not pretend that a card, UPI ID or gift card was actually
/// saved/redeemed. Real persistence should be connected to a backend
/// repository/service before enabling those operations.
class GiftCardsPage extends StatefulWidget {
  const GiftCardsPage({super.key});

  @override
  State<GiftCardsPage> createState() => _GiftCardsPageState();
}

class _GiftCardsPageState extends State<GiftCardsPage> {
  final TextEditingController _giftCardController = TextEditingController();

  bool _isRedeeming = false;

  bool _isAddingUpi = false;

  bool _isAddingCard = false;

  String? _errorMessage;

  // In-memory UI representation only.
  //
  // Replace this with repository-backed data
  // when payment/profile backend is connected.
  String? _savedUpiId;

  final List<SavedCardViewModel> _savedCards = <SavedCardViewModel>[];

  @override
  void dispose() {
    _giftCardController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Gift card
  // ---------------------------------------------------------------------------

  Future<void> _redeemGiftCard() async {
    final code = _giftCardController.text.trim();

    if (code.isEmpty) {
      _showMessage('Enter a gift card code.');
      return;
    }

    if (code.length < 6) {
      _showMessage('Please enter a valid gift card code.');
      return;
    }

    if (_isRedeeming) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isRedeeming = true;
      _errorMessage = null;
    });

    try {
      // ---------------------------------------------------------------------
      // PRODUCTION:
      //
      // Replace this block with:
      //
      // final result = await giftCardRepository.redeem(
      //   code: code,
      // );
      //
      // Never trust a client-side balance calculation.
      // The backend must validate:
      // - code
      // - expiration
      // - activation
      // - remaining balance
      // - user eligibility
      // - fraud/risk rules
      // ---------------------------------------------------------------------

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }

      _giftCardController.clear();

      _showMessage('Gift card submitted for verification.');

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _normalizeError(error);
      });
    } finally {
      if (!mounted) {
        // ignore: control_flow_in_finally
        return;
      }

      setState(() {
        _isRedeeming = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // UPI
  // ---------------------------------------------------------------------------

  Future<void> _addUpi() async {
    if (_isAddingUpi) {
      return;
    }

    final controller = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add UPI ID'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'UPI ID',
              hintText: 'name@bank',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              final value = controller.text.trim();

              if (_isValidUpi(value)) {
                Navigator.of(dialogContext).pop(value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (!_isValidUpi(value)) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Enter a valid UPI ID.')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _isAddingUpi = true;
      _errorMessage = null;
    });

    try {
      // ---------------------------------------------------------------------
      // PRODUCTION:
      //
      // UPI should be verified/linked through your actual payment/account
      // backend. Do not treat entering a VPA as verification.
      // ---------------------------------------------------------------------

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }

      setState(() {
        _savedUpiId = result;
      });

      _showMessage('UPI ID added.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _normalizeError(error);
      });
    } finally {
      if (!mounted) {
        // ignore: control_flow_in_finally
        return;
      }

      setState(() {
        _isAddingUpi = false;
      });
    }
  }

  bool _isValidUpi(String value) {
    if (value.isEmpty) {
      return false;
    }

    if (value.length > 100) {
      return false;
    }

    final regex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+$');

    return regex.hasMatch(value);
  }

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------

  Future<void> _addCard() async {
    if (_isAddingCard) {
      return;
    }

    setState(() {
      _isAddingCard = true;
      _errorMessage = null;
    });

    try {
      // ---------------------------------------------------------------------
      // PRODUCTION:
      //
      // Do NOT collect/store raw card number, CVV or expiry in your own
      // database unless your PCI-compliant architecture explicitly requires
      // it.
      //
      // Prefer the payment gateway's secure tokenization/payment UI.
      // ---------------------------------------------------------------------

      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (!mounted) {
        return;
      }

      _showMessage(
        'Secure card setup should be connected to the payment gateway.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _normalizeError(error);
      });
    } finally {
      if (!mounted) {
        // ignore: control_flow_in_finally
        return;
      }

      setState(() {
        _isAddingCard = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Delete card
  // ---------------------------------------------------------------------------

  Future<void> _removeCard(SavedCardViewModel card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove saved card?'),
          content: Text(
            'Remove ${card.maskedNumber} '
            'from your saved payment methods?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _savedCards.removeWhere((item) => item.id == card.id);
    });

    _showMessage('Card removed.');
  }

  // ---------------------------------------------------------------------------
  // Transaction history
  // ---------------------------------------------------------------------------

  void _openTransactionHistory() {
    _showMessage('Transaction history is not connected yet.');
  }

  // ---------------------------------------------------------------------------
  // Help
  // ---------------------------------------------------------------------------

  void _openHelp() {
    context.push('/account/faqs');
  }

  // ---------------------------------------------------------------------------
  // Gift card dialog
  // ---------------------------------------------------------------------------

  Future<void> _showRedeemDialog() async {
    _giftCardController.clear();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Redeem gift card'),
          content: TextField(
            controller: _giftCardController,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            maxLength: 50,
            decoration: const InputDecoration(
              hintText: 'Enter gift card code',
              labelText: 'Gift card code',
              prefixIcon: Icon(Icons.card_giftcard_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isRedeeming
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                    },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _isRedeeming
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();

                      _redeemGiftCard();
                    },
              child: _isRedeeming
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Redeem'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gift cards & wallet')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _buildWalletCard(context),

              const SizedBox(height: 24),

              _buildSectionTitle(context, 'Gift cards'),

              const SizedBox(height: 8),

              _buildGiftCardTile(context),

              const SizedBox(height: 16),

              _buildPromotionalBanners(context),

              const SizedBox(height: 24),

              _buildSavedCardsSection(context),

              const SizedBox(height: 24),

              _buildUpiSection(context),

              const SizedBox(height: 24),

              _buildOtherOptions(context),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorBanner(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    // Replace with actual repository calls
    // once backend integration is ready.
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildWalletCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet balance',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹0 available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showRedeemDialog,
                child: const Text('Redeem gift card'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _buildGiftCardTile(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.card_giftcard_outlined),
        title: const Text('Add a gift card'),
        subtitle: const Text('Redeem a code and use it at checkout.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showRedeemDialog,
      ),
    );
  }

  Widget _buildPromotionalBanners(BuildContext context) {
    return Column(
      children: [
        _buildBanner(
          context,
          title: 'Gift Cards for all Occasions',
          icon: Icons.card_giftcard_outlined,
          onTap: () {
            _showMessage('Gift card catalogue opened.');
          },
        ),
        const SizedBox(height: 10),
        _buildBanner(
          context,
          title: 'Manara Axis Bank Credit Card',
          icon: Icons.credit_card_outlined,
          onTap: () {
            _showMessage('Credit card offer opened.');
          },
        ),
      ],
    );
  }

  Widget _buildBanner(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Saved cards'),
        const SizedBox(height: 4),
        Text(
          'Save supported payment methods for faster checkout.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        if (_savedCards.isEmpty)
          _buildEmptyCardState(
            context,
            icon: Icons.credit_card_outlined,
            title: 'No saved cards',
            subtitle: 'Your securely tokenized cards will appear here.',
          )
        else
          ..._savedCards.map(
            (card) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSavedCard(context, card),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isAddingCard ? null : _addCard,
            icon: _isAddingCard
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_card_outlined),
            label: Text(
              _isAddingCard ? 'Opening secure setup...' : 'Add new card',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedCard(BuildContext context, SavedCardViewModel card) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.credit_card),
        title: Text(card.brand),
        subtitle: Text(card.maskedNumber),
        trailing: IconButton(
          tooltip: 'Remove card',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _removeCard(card),
        ),
      ),
    );
  }

  Widget _buildUpiSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'UPI'),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(_savedUpiId ?? 'No UPI IDs saved'),
            subtitle: Text(
              _savedUpiId == null
                  ? 'Add a UPI ID for faster checkout.'
                  : 'Saved payment method',
            ),
            trailing: TextButton(
              onPressed: _isAddingUpi ? null : _addUpi,
              child: Text(_isAddingUpi ? 'Adding...' : 'Add UPI'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction history'),
            subtitle: const Text('View your payment activity.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openTransactionHistory,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            subtitle: const Text('Get help with payments and gift cards.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openHelp,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCardState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  String _normalizeError(Object error) {
    final message = error.toString().trim();

    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

/// UI model for a saved card.
///
/// This intentionally contains only non-sensitive information.
/// Never store CVV or raw card numbers here.
@immutable
class SavedCardViewModel {
  const SavedCardViewModel({
    required this.id,
    required this.brand,
    required this.maskedNumber,
  });

  final String id;

  final String brand;

  final String maskedNumber;
}
