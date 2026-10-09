import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TwoFactorAuthScreen extends ConsumerStatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  ConsumerState<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends ConsumerState<TwoFactorAuthScreen> {
  bool _isLoading = true;
  bool _isMfaSupported = false;
  List<Factor> _factors = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkMfaStatus();
  }

  Future<void> _checkMfaStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      // In the current Supabase SDK, mfa.listFactors returns a MfaListFactorsResponse
      // However, if MFA is not enabled in the project, it might throw an AuthException.
      client.auth.mfa.getAuthenticatorAssuranceLevel();
      final factorsResponse = await client.auth.mfa.listFactors();
      
      if (mounted) {
        setState(() {
          _isMfaSupported = true;
          _factors = factorsResponse.all; // Access the list of factors if possible
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isMfaSupported = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMfaSupported = false;
          _errorMessage = 'Two-factor authentication is not configured for this project. Please contact the administrator.';
        });
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
            Text('Two-Factor Authentication', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Add an extra layer of protection to your account.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF5A31F4)))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSecurityOverviewCard(isDark),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Available Authentication Methods', isDark),
                        _buildMfaMethodsSection(isDark),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Keep your account secure', isDark),
                        _buildSecurityGuidance(isDark),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityOverviewCard(bool isDark) {
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
          Icon(Icons.shield_outlined, color: isDark ? const Color(0xFF5A31F4) : const Color(0xFF5A31F4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Two-factor authentication adds another verification step when signing in. Available methods depend on the security features configured for your account.",
                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isMfaSupported && _factors.isNotEmpty ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    !_isMfaSupported ? 'Status Unavailable' : (_factors.isNotEmpty ? 'Enabled' : 'Not enabled'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: !_isMfaSupported ? Colors.grey : (_factors.isNotEmpty ? Colors.green : Colors.grey),
                    ),
                  ),
                ),
              ],
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

  Widget _buildMfaMethodsSection(bool isDark) {
    if (!_isMfaSupported) {
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
            Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: isDark ? Colors.orange[400] : Colors.orange[700]),
                const SizedBox(width: 12),
                Text('Unsupported Configuration', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[800])),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Two-factor authentication is not fully configured for this project.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 13, height: 1.5),
            ),
          ],
        ),
      );
    }

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A31F4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Color(0xFF5A31F4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Authenticator App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                    const SizedBox(height: 4),
                    Text('Generates time-based verification codes.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: null, // Disabled dynamically because we aren't faking setup flows
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.grey[300] : const Color(0xFF0F0F11),
              side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Setup Unavailable'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityGuidance(bool isDark) {
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
          _buildGuideline(Icons.password_outlined, 'Use a unique, strong password', isDark),
          const SizedBox(height: 12),
          _buildGuideline(Icons.phone_android_outlined, 'Keep access to your verification device secure', isDark),
          const SizedBox(height: 12),
          _buildGuideline(Icons.visibility_off_outlined, 'Never share verification codes', isDark),
          const SizedBox(height: 12),
          _buildGuideline(Icons.history_outlined, 'Review unfamiliar sessions and sign-in activity', isDark),
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
