import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/auth_repository.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> with SingleTickerProviderStateMixin {
  final _authRepo = AuthRepository();
  final int _otpLength = 6;
  
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  
  bool _isLoading = false;
  bool _isResending = false;
  
  Timer? _countdownTimer;
  int _countdown = 0;
  final int _cooldownDuration = 30;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (index) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (index) => FocusNode());
    
    _startCooldown();

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
    _animController.forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _countdown = _cooldownDuration;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    
    if (name.length <= 2) {
      return '${name.substring(0, 1)}***@$domain';
    }
    
    return '${name.substring(0, 2)}***@$domain';
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  bool get _isComplete => _otpCode.length == _otpLength;

  void _onPaste(String value) {
    if (value.length == _otpLength && RegExp(r'^[0-9]+$').hasMatch(value)) {
      for (int i = 0; i < _otpLength; i++) {
        _controllers[i].text = value[i];
      }
      _focusNodes[_otpLength - 1].requestFocus();
      setState(() {});
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _onPaste(value);
      return;
    }
    
    if (value.isNotEmpty && index < _otpLength - 1) {
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

  Future<void> _verifyOTP() async {
    if (!_isComplete) return;

    setState(() => _isLoading = true);

    try {
      await _authRepo.verifyOTP(
        email: widget.email,
        token: _otpCode,
        type: OtpType.signup, 
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully.'),
            backgroundColor: Color(0xFFE2F0D9),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Let the root SplashWrapper resolve the session state
        context.go('/');
      }
    } catch (error) {
      if (mounted) {
        String msg = 'Something went wrong. Please try again.';
        final errStr = error.toString().toLowerCase();

        if (errStr.contains('expired')) {
          msg = 'This code has expired. Please request a new code.';
        } else if (errStr.contains('invalid') || errStr.contains('incorrect')) {
          msg = 'The code is incorrect. Please check it and try again.';
        } else if (errStr.contains('rate limit') || errStr.contains('too many')) {
          msg = 'Too many verification attempts. Please wait and try again.';
        } else if (errStr.contains('network') || errStr.contains('connection')) {
          msg = "We couldn't verify the code. Please check your connection and try again.";
        }
        
        _showError(msg);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_countdown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      await _authRepo.resendOTP(
        email: widget.email,
        type: OtpType.signup,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new verification code has been sent.'),
            backgroundColor: Color(0xFFE4DBF6),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _startCooldown();
      }
    } catch (error) {
      if (mounted) {
        _showError('We couldn\'t resend the code right now. Please try again later.');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
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
                              const SizedBox(height: 40),
                              _buildOTPFields(),
                              const SizedBox(height: 40),
                              _buildVerifyButton(),
                              const SizedBox(height: 24),
                              _buildResendSection(),
                              const SizedBox(height: 16),
                              _buildChangeEmail(),
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
        const Text(
          'GovPrep AI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F0F11),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Verify your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F0F11),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter the verification code we sent to your email.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Code sent to\n${_maskEmail(widget.email)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
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
                    LengthLimitingTextInputFormatter(6), // allowing paste
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
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: (_isLoading || !_isComplete) ? null : _verifyOTP,
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
                'Verify Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          "Didn't receive the code?",
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _countdown > 0 || _isResending ? null : _resendOTP,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: _isResending
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0F0F11).withValues(alpha: 0.5)),
                    ),
                  )
                : Text(
                    _countdown > 0 ? 'Resend code in ${_countdown}s' : 'Resend code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _countdown > 0
                          ? const Color(0xFF0F0F11).withValues(alpha: 0.4)
                          : const Color(0xFF0F0F11),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeEmail() {
    return Center(
      child: InkWell(
        onTap: () => context.push('/register'),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            'Change email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F0F11).withValues(alpha: 0.6),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
