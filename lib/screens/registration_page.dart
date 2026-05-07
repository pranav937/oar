import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/otr_theme.dart';
import '../widgets/otr_text_field.dart';
import '../services/api_service.dart';
import '../utils/custom_toast.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  int _currentStep = 0;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Controllers for registration
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hasAcceptedDeclaration = false;

  // Controllers for OTP
  final _emailOtpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final _mobileOtpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  Future<void> _handleRegister() async {
    final email = _emailController.text;
    final mobile = _mobileController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid email address')));
      return;
    }

    // Mobile validation (10 digits)
    final mobileRegex = RegExp(r'^\d{10}$');
    if (!mobileRegex.hasMatch(mobile)) {
      if (mounted) {
        CustomToast.showSuccess(
          context,
          'Mobile number must be exactly 10 digits',
        );
      }
      return;
    }

    // Password complexity validation
    if (password.length < 8) {
      if (mounted) {
        CustomToast.showSuccess(
          context,
          'Password must be at least 8 characters',
        );
      }
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      if (mounted) {
        CustomToast.showSuccess(
          context,
          'Password must contain an uppercase letter',
        );
      }
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      if (mounted) {
        CustomToast.showSuccess(
          context,
          'Password must contain a lowercase letter',
        );
      }
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      CustomToast.showSuccess(context, 'Password must contain a number');
      return;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      if (mounted) {
        CustomToast.showSuccess(
          context,
          'Password must contain a special character',
        );
      }
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (!_hasAcceptedDeclaration) {
      if (mounted) {
        CustomToast.showSuccess(context, 'Please accept the declaration');
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userData = {
        "email": _emailController.text,
        "mobileNumber": _mobileController.text,
        "password": _passwordController.text,
        "confirmPassword": _confirmPasswordController.text,
        "hasAcceptedDeclaration": _hasAcceptedDeclaration,
      };

      debugPrint("DEBUG: Sending registration data: $userData");

      final result = await _apiService.register(userData);

      if (result['success'] == true) {
        // Move to OTP step
        if (mounted) {
          setState(() => _currentStep = 1);
        }
      } else {
        if (mounted) {
          String errorMsg = result['message'] ?? 'Registration failed';
          if (result['errors'] != null &&
              result['errors'] is List &&
              (result['errors'] as List).isNotEmpty) {
            final firstError = (result['errors'] as List).first;
            errorMsg = firstError['message'] ?? errorMsg;
          }
          CustomToast.showError(context, errorMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    String emailOtp = _emailOtpControllers.map((c) => c.text).join();
    String mobileOtp = _mobileOtpControllers.map((c) => c.text).join();

    if (emailOtp.length < 6 || mobileOtp.length < 6) {
      if (mounted) {
        CustomToast.showSuccess(
          context,
          'Please enter both code verification values',
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final emailResult = await _apiService.verifyEmailOtp(
        _emailController.text,
        emailOtp,
      );
      final mobileResult = await _apiService.verifyMobileOtp(
        _mobileController.text,
        mobileOtp,
      );

      if (emailResult['success'] == true && mobileResult['success'] == true) {
        if (mounted) {
          _finishRegistration(context);
        }
      } else {
        String msg = "";
        if (emailResult['success'] != true) {
          String eMsg = emailResult['message'] ?? 'Email OTP failed';
          if (emailResult['errors'] != null &&
              emailResult['errors'] is List &&
              (emailResult['errors'] as List).isNotEmpty) {
            eMsg = (emailResult['errors'] as List).first['message'] ?? eMsg;
          }
          msg += "Email: $eMsg. ";
        }
        if (mobileResult['success'] != true) {
          String mMsg = mobileResult['message'] ?? 'Mobile OTP failed';
          if (mobileResult['errors'] != null &&
              mobileResult['errors'] is List &&
              (mobileResult['errors'] as List).isNotEmpty) {
            mMsg = (mobileResult['errors'] as List).first['message'] ?? mMsg;
          }
          msg += "Mobile: $mMsg. ";
        }
        if (mounted) {
          CustomToast.showError(context, msg);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _finishRegistration(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OtrTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: OtrTheme.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Created!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Your registration is complete. Welcome to OTR Model! Please log in to your new account.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OtrTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceed to Login',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: OtrTheme.primaryBlue.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                        onPressed: () {
                          if (_currentStep > 0) {
                            setState(() => _currentStep--);
                          } else {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: OtrTheme.darkNavy,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),

                _buildProgressIndicator(),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _buildCurrentStep(),
                      ),
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

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(2, (index) {
                  bool isCompleted = index < _currentStep;
                  bool isActive = index == _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive
                          ? OtrTheme.primaryBlue
                          : OtrTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted || isActive
                            ? OtrTheme.primaryBlue
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isActive ? OtrTheme.intenseShadow : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.white
                                    : Colors.grey.shade400,
                              ),
                            ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registration',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _currentStep >= 0
                      ? OtrTheme.primaryBlue
                      : Colors.grey.shade400,
                ),
              ),
              Text(
                'Verification',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _currentStep >= 1
                      ? OtrTheme.primaryBlue
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStepDetails();
      case 1:
        return _buildStepOtp();
      default:
        return _buildStepDetails();
    }
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: OtrTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: OtrTheme.primaryBlue, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: OtrTheme.darkNavy,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black45,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStepDetails() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          'Join Us',
          'Create your secure account to access the system.',
          Icons.person_add_rounded,
        ),
        OtrTextField(
          label: 'Email Address',
          hintText: 'name@example.com',
          icon: Icons.alternate_email_rounded,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Mobile Number',
          hintText: '10-digit mobile number',
          icon: Icons.phone_iphone_rounded,
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Password',
          hintText: 'Create a strong password',
          icon: Icons.lock_person_outlined,
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Confirm Password',
          hintText: 'Verify your password',
          icon: Icons.verified_user_outlined,
          isPassword: true,
          controller: _confirmPasswordController,
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: OtrTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OtrTheme.dividerColor),
          ),
          child: CheckboxListTile(
            title: const Text(
              'I declare that all info is correct.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            value: _hasAcceptedDeclaration,
            onChanged: (val) =>
                setState(() => _hasAcceptedDeclaration = val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: OtrTheme.primaryBlue,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: OtrTheme.intenseShadow,
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'CONTINUE',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStepOtp() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          'Verification',
          'We have sent codes to your email and phone.',
          Icons.security_rounded,
        ),
        const Text(
          'EMAIL OTP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.black38,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) => _buildOtpBox(index, _emailOtpControllers),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'MOBILE OTP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.black38,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) => _buildOtpBox(index, _mobileOtpControllers),
          ),
        ),
        const SizedBox(height: 48),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: OtrTheme.intenseShadow,
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleVerifyOtp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'VERIFY & REGISTER',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildOtpBox(int index, List<TextEditingController> controllers) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: OtrTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OtrTheme.dividerColor, width: 2),
        boxShadow: OtrTheme.softShadow,
      ),
      child: TextField(
        controller: controllers[index],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: OtrTheme.darkNavy,
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}
