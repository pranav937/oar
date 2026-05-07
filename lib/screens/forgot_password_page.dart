import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/otr_theme.dart';
import '../widgets/otr_text_field.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/custom_toast.dart';

enum ForgotPasswordStep { mobile, otp, reset }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _mobileController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  ForgotPasswordStep _currentStep = ForgotPasswordStep.mobile;

  Future<void> _handleSendOtp() async {
    final mobile = _mobileController.text.trim();
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    if (!mobileRegex.hasMatch(mobile)) {
      CustomToast.showError(context, 'Mobile number must be exactly 10 digits and start with 6-9');
      return;
    }
    
    if (RegExp(r'^(\d)\1{9}$').hasMatch(mobile)) {
      CustomToast.showError(context, 'Mobile number cannot be all same digits');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _apiService.forgotPassword(mobile);
      if (result['success'] == true) {
        if (mounted) {
          CustomToast.showSuccess(context, result['message'] ?? 'OTP sent successfully');
          
          // Pre-fill OTP logic removed as per user request
          setState(() => _currentStep = ForgotPasswordStep.otp);
        }
      } else {
        if (mounted) {
          CustomToast.showSuccess(context, result['message'] ?? 'Failed to send OTP');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, 'An error occurred: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      CustomToast.showSuccess(context, 'Please enter 6 digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _apiService.verifyMobileOtp(_mobileController.text.trim(), otp);
      if (result['success'] == true) {
        if (mounted) {
          CustomToast.showSuccess(context, 'OTP Verified Successfully!');
          setState(() => _currentStep = ForgotPasswordStep.reset);
        }
      } else {
        if (mounted) {
          CustomToast.showSuccess(context, result['message'] ?? 'Verification failed');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, 'An error occurred: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || password.length < 6) {
      CustomToast.showSuccess(context, 'Password must be at least 6 characters');
      return;
    }

    if (password.contains(' ')) {
      CustomToast.showError(context, 'Password cannot contain spaces');
      return;
    }

    if (password != confirmPassword) {
      CustomToast.showError(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final otp = _otpControllers.map((c) => c.text).join();
      final result = await _apiService.resetPassword(_mobileController.text.trim(), password, confirmPassword, otp);
      if (result['success'] == true) {
        if (mounted) {
          CustomToast.showSuccess(context, result['message'] ?? 'Password reset successfully');
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } else {
        if (mounted) {
          CustomToast.showSuccess(context, result['message'] ?? 'Failed to reset password');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, 'An error occurred: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: OtrTheme.darkNavy, size: 20),
          onPressed: () {
            if (_currentStep == ForgotPasswordStep.otp) {
              setState(() => _currentStep = ForgotPasswordStep.mobile);
            } else if (_currentStep == ForgotPasswordStep.reset) {
              setState(() => _currentStep = ForgotPasswordStep.otp);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              _currentStep == ForgotPasswordStep.mobile 
                  ? 'Forgot Password' 
                  : _currentStep == ForgotPasswordStep.otp 
                      ? 'Verify OTP' 
                      : 'Reset Password',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
            ),
            const SizedBox(height: 12),
            Text(
              _currentStep == ForgotPasswordStep.mobile
                  ? 'Enter your registered mobile number to receive an OTP'
                  : _currentStep == ForgotPasswordStep.otp
                      ? 'Enter the 6 digit code sent to +91 ${_mobileController.text}'
                      : 'Enter your new password below',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 60),
            if (_currentStep == ForgotPasswordStep.mobile) ...[
              OtrTextField(
                label: 'Mobile Number',
                hintText: 'Enter 10 digit number',
                icon: Icons.phone_android_rounded,
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSendOtp,
                child: _isLoading
                    ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                    : const Text('Send OTP'),
              ),
            ] else if (_currentStep == ForgotPasswordStep.otp) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerifyOtp,
                child: _isLoading
                    ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                    : const Text('Verify OTP'),
              ),
            ] else if (_currentStep == ForgotPasswordStep.reset) ...[
              OtrTextField(
                label: 'New Password',
                hintText: 'Enter new password',
                icon: Icons.lock_rounded,
                controller: _passwordController,
                isPassword: true,
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
              ),
              const SizedBox(height: 20),
              OtrTextField(
                label: 'Confirm Password',
                hintText: 'Re-enter new password',
                icon: Icons.lock_reset_rounded,
                controller: _confirmPasswordController,
                isPassword: true,
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                child: _isLoading
                    ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                    : const Text('Change Password'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _otpControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: OtrTheme.darkNavy,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        textAlignVertical: TextAlignVertical.center,
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
          if (v.isEmpty && index > 0) FocusScope.of(context).previousFocus();
        },
      ),
    );
  }
}
