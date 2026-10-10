import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/profile_store.dart';
import 'otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _usePhone = false;

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _identity => _identityController.text.trim();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    ProfileStore.save(
      name: _identity.contains('@')
          ? _identity.split('@').first
          : 'Manara shopper',
      email: _identity.contains('@') ? _identity : '$_identity@manara.app',
    );
    context.go('/');
  }

  void _loginWithOtp() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationPage(
          identity: _identity,
          name: _identity.contains('@')
              ? _identity.split('@').first
              : 'Manara shopper',
          isRegistration: false,
        ),
      ),
    );
  }

  void _loginWithGoogle() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const OtpVerificationPage(
          identity: 'Google account',
          name: 'Google shopper',
          isRegistration: false,
        ),
      ),
    );
  }

  void _forgotPassword() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset password'),
        content: const Text(
          'We will send a reset link or OTP to your registered contact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FF),
    appBar: AppBar(
      title: const Text('Sign in'),
      backgroundColor: const Color(0xFF2874F0),
      foregroundColor: Colors.white,
    ),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
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
                    child: Row(
                      children: [
                        Image.asset(AppAssets.logo, width: 58, height: 58),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Welcome back to Manara Store',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Welcome to Manara Store',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue shopping',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
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
                  TextFormField(
                    controller: _identityController,
                    keyboardType: _usePhone
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (_usePhone) {
                        return text.length < 10
                            ? 'Enter a valid mobile number'
                            : null;
                      }
                      return !text.contains('@')
                          ? 'Enter a valid email address'
                          : null;
                    },
                    decoration: InputDecoration(
                      labelText: _usePhone ? 'Mobile number' : 'Email address',
                      prefixIcon: Icon(
                        _usePhone ? Icons.phone_outlined : Icons.email_outlined,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) => value == null || value.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F00),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Login with password'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _loginWithOtp,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Login with OTP'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _loginWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/register'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: const Color(0xFF2874F0),
                    ),
                    child: const Text('Create new account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
