import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class TwoFactorVerificationScreen extends ConsumerStatefulWidget {
  const TwoFactorVerificationScreen({super.key});

  @override
  ConsumerState<TwoFactorVerificationScreen> createState() => _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState extends ConsumerState<TwoFactorVerificationScreen> with SingleTickerProviderStateMixin {
  final int _codeLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _isLoading = true;
  bool _isConfigured = false;
  String? _factorId;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_codeLength, (index) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (index) => FocusNode());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _checkMfaStatus();
  }

  Future<void> _checkMfaStatus() async {
    try {
      final factors = await Supabase.instance.client.auth.mfa.listFactors();
      final totpFactors = factors.all.where((f) => f.factorType == FactorType.totp && f.status == FactorStatus.verified).toList();

      if (mounted) {
        setState(() {
          _isConfigured = totpFactors.isNotEmpty;
          if (_isConfigured) {
            _factorId = totpFactors.first.id;
          }
          _isLoading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConfigured = false;
          _isLoading = false;
        });
        _animController.forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  String get _verificationCode => _controllers.map((c) => c.text).join();
  bool get _isComplete => _verificationCode.length == _codeLength;

  void _onPaste(String value) {
    if (value.length == _codeLength && RegExp(r'^[0-9]+$').hasMatch(value)) {
      for (int i = 0; i < _codeLength; i++) {
        _controllers[i].text = value[i];
      }
      _focusNodes[_codeLength - 1].requestFocus();
      setState(() {});
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _onPaste(value);
      return;
    }

    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
        setState(() {});
      }
    }
  }

  Future<void> _verifyCode() async {
    if (!_isComplete || _factorId == null) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.mfa.challengeAndVerify(
        factorId: _factorId!,
        code: _verificationCode,
      );

      if (mounted) {
        // Validation succeeded. Route to root to handle authenticated flow.
        context.go('/');
      }
    } catch (error) {
      if (mounted) {
        String msg = 'Something went wrong. Please try again.';
        final errStr = error.toString().toLowerCase();

        if (errStr.contains('invalid') || errStr.contains('incorrect')) {
          msg = 'The verification code is incorrect. Please try again.';
        } else if (errStr.contains('expired')) {
          msg = 'This verification request has expired. Please start verification again.';
        } else if (errStr.contains('rate limit') || errStr.contains('too many')) {
          msg = 'Too many verification attempts. Please wait and try again.';
        } else if (errStr.contains('network') || errStr.contains('connection')) {
          msg = "We couldn't complete verification. Check your connection and try again.";
        } else if (errStr.contains('session')) {
          msg = 'Your authentication session is no longer valid. Please sign in again.';
        }

        _showError(msg);
        setState(() {
          _isLoading = false;
          // Clear code fields on error
          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE4F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 600;
            return Stack(
              children: [
                _buildBackgroundShapes(),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          width: isDesktop ? 480 : constraints.maxWidth * 0.95,
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F0F11).withValues(alpha: 0.03),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 32),
                              if (_isLoading && !_isConfigured) 
                                const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11)),
                                  ),
                                )
                              else if (!_isConfigured)
                                _buildUnavailableState()
                              else ...[
                                _buildCodeFields(),
                                const SizedBox(height: 24),
                                _buildVerifyButton(),
                                const SizedBox(height: 24),
                                _buildSecurityPanel(),
                              ],
                              const SizedBox(height: 24),
                              _buildBackToSignIn(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFE4DBF6).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0D9).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.shield_outlined,
          size: 40,
          color: Color(0xFF0F0F11),
        ),
        const SizedBox(height: 16),
        const Text(
          'GovPrep AI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F0F11),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Two-factor authentication',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Verify your identity to securely continue to GovPrep AI.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildUnavailableState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDF0D5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            size: 28,
            color: Color(0xFF0F0F11),
          ),
          const SizedBox(height: 12),
          const Text(
            'Two-factor authentication unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0F11),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Two-factor authentication is not currently configured for this account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your authentication code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Open your authenticator app and enter the 6-digit verification code.',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_codeLength, (index) {
            return Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onKeyEvent(index, event),
                  child: Semantics(
                    label: 'Verification code digit ${index + 1}',
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F0F11),
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: _controllers[index].text.isNotEmpty
                            ? const Color(0xFFE4DBF6).withValues(alpha: 0.3)
                            : const Color(0xFFF3F4F6).withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFF0F0F11).withValues(alpha: 0.05)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _controllers[index].text.isNotEmpty
                                ? const Color(0xFFE4DBF6)
                                : const Color(0xFF0F0F11).withValues(alpha: 0.05),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0F0F11), width: 1.5),
                        ),
                      ),
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: (_isLoading || !_isComplete) ? null : _verifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F0F11),
          foregroundColor: const Color(0xFFFFFFFF),
          disabledBackgroundColor: const Color(0xFFF3F4F6),
          disabledForegroundColor: const Color(0xFF0F0F11).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F0F11)),
                ),
              )
            : const Text(
                'Verify and continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2ECE9).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline, size: 16, color: Color(0xFF0F0F11)),
              const SizedBox(width: 8),
              Text(
                'Secure verification',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Two-factor authentication adds an extra layer of protection to your account.',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToSignIn() {
    return Center(
      child: InkWell(
        onTap: () async {
          final authRepo = ref.read(authRepositoryProvider);
          await authRepo.signOut();
          if (mounted) context.go('/login');
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back,
                size: 16,
                color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Back to sign in',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
