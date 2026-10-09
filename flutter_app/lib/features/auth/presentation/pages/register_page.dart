import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/profile_store.dart';
import 'otp_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _usePhone = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        (!_usePhone && !_emailController.text.contains('@')) ||
        (_usePhone && _phoneController.text.trim().length < 10) ||
        _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid details and a 6+ character password'),
        ),
      );
      return;
    }
    await ProfileStore.save(
      name: _nameController.text.trim(),
      email: _usePhone
          ? '${_phoneController.text.trim()}@manara.app'
          : _emailController.text.trim(),
    );
    if (mounted) context.go('/');
  }

  void _registerWithOtp() {
    final identity = _usePhone
        ? _phoneController.text.trim()
        : _emailController.text.trim();
    final valid =
        _nameController.text.trim().isNotEmpty &&
        ((_usePhone && identity.length >= 10) ||
            (!_usePhone && identity.contains('@')));
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your name and a valid email or mobile number.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationPage(
          identity: identity,
          name: _nameController.text.trim(),
          isRegistration: true,
        ),
      ),
    );
  }

  void _continueWithGoogle() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const OtpVerificationPage(
          identity: 'Google account',
          name: 'Google shopper',
          isRegistration: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: const Color(0xFF2874F0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2874F0), Color(0xFF1554B8)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join Manara Store',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Create your account with email or mobile OTP',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usePhone ? _phoneController : _emailController,
                    keyboardType: _usePhone
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: _usePhone ? 'Mobile number' : 'Email',
                      prefixIcon: Icon(
                        _usePhone ? Icons.phone_outlined : Icons.mail_outline,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Email')),
                      ButtonSegment(value: true, label: Text('Mobile')),
                    ],
                    selected: {_usePhone},
                    onSelectionChanged: (selection) =>
                        setState(() => _usePhone = selection.first),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Create account'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _registerWithOtp,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Create with OTP'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _continueWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: const Color(0xFF2874F0),
                    ),
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
