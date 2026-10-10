import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onGoogleTap,
    required this.onOtpTap,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback? onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoogleTap;
  final VoidCallback onOtpTap;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email or mobile',
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) {
              return 'Please enter your email or mobile number.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          validator: (value) {
            if ((value ?? '').length < 6) {
              return 'Password must be at least 6 characters.';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.onForgotPassword,
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.onSubmit,
            icon: const Icon(Icons.login_rounded),
            label: const Text('Sign in'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onOtpTap,
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Continue with OTP'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onGoogleTap,
            icon: const Icon(Icons.g_mobiledata_rounded),
            label: const Text('Continue with Google'),
          ),
        ),
      ],
    );
  }
}
