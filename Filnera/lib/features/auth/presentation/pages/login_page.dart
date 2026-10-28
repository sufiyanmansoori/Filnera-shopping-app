import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/profile_store.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../auth_return_handler.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.returnTo});

  final String? returnTo;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _identity => _identityController.text.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    try {
      await auth.loginWithEmail(
        email: _identity,
        password: _passwordController.text,
      );
      if (!mounted) return;
      final session = auth.currentUser;
      if (!auth.isAuthenticated || session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Unable to sign in.')),
        );
        return;
      }
      await ProfileStore.save(name: session.fullName, email: session.email);
      await cart.fetchCart(session.userId);
      if (!mounted) return;
      await AuthReturnHandler.complete(context, returnTo: widget.returnTo);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _forgotPassword() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset password'),
        content: const Text(
          'Password recovery is not configured yet. Please contact support.',
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
                  TextFormField(
                    controller: _identityController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      return !text.contains('@')
                          ? 'Enter a valid email address'
                          : null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: const Icon(Icons.email_outlined),
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
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F00),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login with password'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      final returnTo = AuthReturnHandler.safeLocation(
                        widget.returnTo,
                      );
                      context.push(
                        '/register?returnTo=${Uri.encodeComponent(returnTo)}',
                      );
                    },
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
