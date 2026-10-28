import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/profile_store.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../auth_return_handler.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.returnTo});

  final String? returnTo;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isSubmitting) return;
    if (_nameController.text.trim().isEmpty ||
        !_emailController.text.trim().contains('@') ||
        _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid details and a 6+ character password'),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    try {
      await auth.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );
      if (!mounted) return;
      final session = auth.currentUser;
      if (!auth.isAuthenticated || session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Unable to create your account.'),
          ),
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
                          'Create your Filnera account',
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
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.mail_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Mobile number (optional)',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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
                      onPressed: _isSubmitting ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      final returnTo = AuthReturnHandler.safeLocation(
                        widget.returnTo,
                      );
                      context.push(
                        '/login?returnTo=${Uri.encodeComponent(returnTo)}',
                      );
                    },
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
