import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/profile_store.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.identity,
    required this.name,
    required this.isRegistration,
  });

  final String identity;
  final String name;
  final bool isRegistration;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpController.text.trim() != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP sent to you.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await ProfileStore.save(
      name: widget.name.isEmpty ? 'Manara shopper' : widget.name,
      email: widget.identity.contains('@')
          ? widget.identity
          : '${widget.identity}@manara.app',
    );
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verify account')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.verified_user_outlined, size: 64),
              const SizedBox(height: 20),
              Text(
                'Verify ${widget.isRegistration ? 'your new account' : 'your login'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the OTP sent to ${widget.identity}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _otpController,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: '6-digit OTP',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demo mode: use OTP 123456. Connect your SMS/email provider for live delivery.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _verify,
                child: Text(
                  _isSubmitting ? 'Verifying...' : 'Verify and continue',
                ),
              ),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('A new OTP has been requested.'),
                  ),
                ),
                child: const Text('Resend OTP'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
