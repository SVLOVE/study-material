import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountRecoveryScreen extends ConsumerStatefulWidget {
  const AccountRecoveryScreen({super.key});

  @override
  ConsumerState<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends ConsumerState<AccountRecoveryScreen> {
  bool _isLoading = false;
  bool _requestSent = false;
  String? _errorMessage;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.email != null) {
      _userEmail = user.email;
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name.substring(0, 1)}***@$domain';
    return '${name.substring(0, 2)}***${name.substring(name.length - 1)}@$domain';
  }

  Future<void> _sendRecoveryEmail() async {
    if (_userEmail == null) {
      setState(() => _errorMessage = 'No email associated with this account.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _requestSent = false;
    });

    try {
      // Assuming Supabase project uses standard redirect configurations.
      // We do not pass an explicit redirect URL here to rely on the backend default,
      // or we can just send it and let the user click the link in their email.
      await Supabase.instance.client.auth.resetPasswordForEmail(_userEmail!);
      
      if (mounted) {
        setState(() {
          _requestSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recovery instructions sent. Please check your email.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text('Account Recovery', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Manage your options for recovering account access.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRecoveryOverview(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Recovery Methods', isDark),
                  _buildEmailRecoveryCard(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Recovery Instructions', isDark),
                  _buildInstructionsCard(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Protect your account', isDark),
                  _buildSecurityRecommendations(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryOverview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.vpn_key_outlined, color: isDark ? const Color(0xFF5A31F4) : const Color(0xFF5A31F4)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Keep your recovery options up to date so you can regain access to your account if you forget your password or lose access to a verification method.",
              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
    );
  }

  Widget _buildEmailRecoveryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.email_outlined, color: Color(0xFF5A31F4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email-based password recovery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail != null ? _maskEmail(_userEmail!) : 'Email unavailable',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_isLoading || _requestSent || _userEmail == null) ? null : _sendRecoveryEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A31F4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_requestSent ? 'Recovery Link Sent' : 'Send password reset link', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          if (_requestSent) ...[
            const SizedBox(height: 12),
            Text(
              'If a matching account exists, recovery instructions will be sent. Please check your inbox and spam folder.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructionStep('1', 'Choose an available recovery method.', isDark),
          const SizedBox(height: 16),
          _buildInstructionStep('2', 'Follow the instructions delivered by the configured provider.', isDark),
          const SizedBox(height: 16),
          _buildInstructionStep('3', 'Complete any required identity verification.', isDark),
          const SizedBox(height: 16),
          _buildInstructionStep('4', 'Set a new password if prompted.', isDark),
          const SizedBox(height: 16),
          _buildInstructionStep('5', 'Sign in again and review your account security.', isDark),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF5A31F4).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Text(number, style: const TextStyle(color: Color(0xFF5A31F4), fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityRecommendations(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuideline(Icons.password, 'Use a unique, strong password', isDark),
          const SizedBox(height: 12),
          _buildGuideline(Icons.link_off, 'Never share password-reset links or verification codes', isDark),
          const SizedBox(height: 12),
          _buildGuideline(Icons.devices_other, 'Avoid opening recovery links on shared devices', isDark),
          const SizedBox(height: 12),
          _buildGuideline(Icons.history, 'Review active sessions and sign-in activity after recovering', isDark),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildNavChip(Icons.password, 'Change Password', '/settings/change-password', isDark),
              _buildNavChip(Icons.devices, 'Active Sessions', '/settings/active-sessions', isDark),
              _buildNavChip(Icons.history, 'Login Activity', '/settings/login-activity', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildNavChip(IconData icon, String label, String route, bool isDark) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: const Color(0xFF5A31F4)),
      label: Text(label, style: const TextStyle(color: Color(0xFF5A31F4), fontSize: 13, fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF5A31F4).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.transparent),
      ),
      onPressed: () => context.push(route),
    );
  }
}
