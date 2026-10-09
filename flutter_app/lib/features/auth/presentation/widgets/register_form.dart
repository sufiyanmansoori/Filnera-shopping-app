import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.onSubmit,
    required this.onGoogleTap,
  });

  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final VoidCallback? onSubmit;
  final VoidCallback onGoogleTap;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.fullNameController,
          decoration: InputDecoration(
            labelText: 'Full name',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          validator: (value) {
            if ((value ?? '').trim().length < 2) {
              return 'Please enter your full name.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email address',
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
            if (!text.contains('@')) {
              return 'Please enter a valid email.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone number',
            prefixIcon: const Icon(Icons.phone_android_outlined),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
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
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.onSubmit,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Create account'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
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
