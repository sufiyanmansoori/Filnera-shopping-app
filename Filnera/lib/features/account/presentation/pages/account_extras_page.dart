import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/profile_store.dart';

/// Production-ready profile editing page.
///
/// Responsibilities:
/// - Load existing profile
/// - Edit name/email
/// - Validate input
/// - Prevent duplicate save requests
/// - Show loading state
/// - Handle errors
/// - Avoid setState/context usage after disposal
/// - Provide accessible form controls
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();

  final FocusNode _emailFocusNode = FocusNode();

  bool _isLoading = true;

  bool _isSaving = false;

  String? _errorMessage;

  bool _hasLoadedProfile = false;

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Profile loading
  // ---------------------------------------------------------------------------

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final profile = await ProfileStore.read();

      if (!mounted) {
        return;
      }

      _nameController.text = (profile['name'] ?? '').toString();

      _emailController.text = (profile['email'] ?? '').toString();

      setState(() {
        _hasLoadedProfile = true;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _normalizeError(error);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    final formState = _formKey.currentState;

    if (formState == null) {
      return;
    }

    if (!formState.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ProfileStore.save(name: name, email: email);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = _normalizeError(error);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Enter your full name.';
    }

    if (name.length < 2) {
      return 'Name must contain at least 2 characters.';
    }

    if (name.length > 100) {
      return 'Name cannot exceed 100 characters.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter your email address.';
    }

    if (email.length > 254) {
      return 'Email address is too long.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Helpers
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasLoadedProfile && _errorMessage != null) {
      return _buildErrorState(context);
    }

    return SafeArea(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(context),

            const SizedBox(height: 24),

            _buildNameField(),

            const SizedBox(height: 16),

            _buildEmailField(),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorBanner(),
            ],

            const SizedBox(height: 24),

            _buildSaveButton(),

            const SizedBox(height: 16),

            _buildSecurityNote(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal information',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Keep your profile information up to date.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      enabled: !_isSaving,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      maxLength: 100,
      decoration: const InputDecoration(
        labelText: 'Full name',
        hintText: 'Enter your full name',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      validator: _validateName,
      onFieldSubmitted: (_) {
        _emailFocusNode.requestFocus();
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      enabled: !_isSaving,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: 'Email address',
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      validator: _validateEmail,
      onFieldSubmitted: (_) {
        _save();
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: _isSaving ? null : _save,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSaving
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Text(key: ValueKey('text'), 'Save profile'),
        ),
      ),
    );
  }

  Widget _buildSecurityNote(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your profile information is stored securely. '
                'Never share your account password or OTP with anyone.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'Unable to load profile',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Please try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
