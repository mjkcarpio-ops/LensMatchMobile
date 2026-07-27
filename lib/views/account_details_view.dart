import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/auth_service.dart';

class AccountDetailsView extends StatefulWidget {
  final CustomerModel? customer;
  final VoidCallback? onProfileUpdated;

  const AccountDetailsView({
    super.key,
    this.customer,
    this.onProfileUpdated,
  });

  @override
  State<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends State<AccountDetailsView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final user = _authService.currentUser;
    _nameController.text = widget.customer?.fullName ?? user?.displayName ?? '';
    _emailController.text = widget.customer?.email ?? user?.email ?? '';
    _phoneController.text = widget.customer?.phoneNumber ?? '';
    _addressController.text = widget.customer?.address ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: isError ? Colors.redAccent.shade700 : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleSaveChanges() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _showSnackBar('Full name cannot be empty.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.updateCustomerProfile(
        uid: user.uid,
        fullName: newName,
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      widget.onProfileUpdated?.call();
      _showSnackBar('Profile updated successfully!', isError: false);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              context,
              label: 'Full Name',
              controller: _nameController,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            _buildField(
              context,
              label: 'Email Address',
              controller: _emailController,
              enabled: false, // Email cannot be edited directly here
              helperText: 'Email address cannot be changed directly.',
            ),
            const SizedBox(height: 24),
            _buildField(
              context,
              label: 'Phone Number',
              controller: _phoneController,
              enabled: !_isLoading,
              hintText: 'Enter phone number (e.g. +1 555-123-4567)',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            _buildField(
              context,
              label: 'Shipping Address',
              controller: _addressController,
              enabled: !_isLoading,
              hintText: 'Enter delivery/shipping address',
              maxLines: 3,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSaveChanges,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF141414),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF141414),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    String? hintText,
    String? helperText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            helperStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
            filled: true,
            fillColor: enabled ? const Color(0xFF141414) : const Color(0xFF0F0F0F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A35)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A35)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A1A22)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
