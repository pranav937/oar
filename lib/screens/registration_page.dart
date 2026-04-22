import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../widgets/otr_text_field.dart';
import '../services/api_service.dart';

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
  final _emailOtpControllers = List.generate(6, (index) => TextEditingController());
  final _mobileOtpControllers = List.generate(6, (index) => TextEditingController());

  Future<void> _handleRegister() async {
    final email = _emailController.text;
    final mobile = _mobileController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || mobile.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email address')));
      return;
    }

    // Mobile validation (10 digits)
    final mobileRegex = RegExp(r'^\d{10}$');
    if (!mobileRegex.hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mobile number must be exactly 10 digits')));
      return;
    }

    // Password complexity validation
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 8 characters')));
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must contain an uppercase letter')));
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must contain a lowercase letter')));
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must contain a number')));
      return;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must contain a special character')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (!_hasAcceptedDeclaration) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please accept the declaration')));
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

      print("DEBUG: Sending registration data: $userData");

      final result = await _apiService.register(userData);

      if (result['success'] == true) {
        // Move to OTP step
        setState(() => _currentStep = 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    String emailOtp = _emailOtpControllers.map((c) => c.text).join();
    String mobileOtp = _mobileOtpControllers.map((c) => c.text).join();

    if (emailOtp.length < 6 || mobileOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both code verification values')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final emailResult = await _apiService.verifyEmailOtp(_emailController.text, emailOtp);
      final mobileResult = await _apiService.verifyMobileOtp(_mobileController.text, mobileOtp);

      if (emailResult['success'] == true && mobileResult['success'] == true) {
        _finishRegistration(context);
      } else {
        String msg = "";
        if (emailResult['success'] != true) msg += "Email OTP: ${emailResult['message']}. ";
        if (mobileResult['success'] != true) msg += "Mobile OTP: ${mobileResult['message']}. ";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 16),
              const Text('Account Created!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Proceed to Login', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () {
                        if (_currentStep > 0) {
                          setState(() => _currentStep--);
                        } else {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: OtrTheme.darkNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildProgressIndicator(),

            const SizedBox(height: 20),

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
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(color: OtrTheme.lightBlue, borderRadius: BorderRadius.circular(2)),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 4,
            width: double.infinity,
            margin: EdgeInsets.only(right: _currentStep == 0 ? 150 : 0),
            decoration: BoxDecoration(color: OtrTheme.primaryBlue, borderRadius: BorderRadius.circular(2)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(2, (index) {
              bool isCompleted = index < _currentStep;
              bool isActive = index == _currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: isActive ? 16 : 12,
                height: isActive ? 16 : 12,
                decoration: BoxDecoration(
                  color: isCompleted || isActive ? OtrTheme.primaryBlue : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted || isActive ? OtrTheme.primaryBlue : OtrTheme.lightBlue,
                    width: 2,
                  ),
                ),
              );
            }),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: OtrTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: OtrTheme.primaryBlue, size: 28),
        ),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.4)),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStepDetails() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Account Details', 'Create your ORA account to get started.', Icons.person_add_rounded),
        OtrTextField(label: 'Email Address', hintText: 'name@example.com', icon: Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        OtrTextField(label: 'Mobile Number', hintText: '10-digit mobile number', icon: Icons.phone_android_rounded, controller: _mobileController, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        OtrTextField(label: 'Password', hintText: 'Create a password', icon: Icons.lock_outline_rounded, isPassword: true, controller: _passwordController),
        const SizedBox(height: 16),
        OtrTextField(label: 'Confirm Password', hintText: 'Re-enter your password', icon: Icons.lock_reset_rounded, isPassword: true, controller: _confirmPasswordController),
        const SizedBox(height: 24),
        CheckboxListTile(
          title: const Text('I hereby declare that the information provided is correct.', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)),
          value: _hasAcceptedDeclaration,
          onChanged: (val) => setState(() => _hasAcceptedDeclaration = val ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: OtrTheme.primaryBlue,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Register & Send OTP'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStepOtp() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Final Verification', 'Enter the codes sent to your email and phone.', Icons.verified_user_rounded),
        
        const Text('EMAIL OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black38, letterSpacing: 1)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOtpBox(index, _emailOtpControllers)),
        ),
        
        const SizedBox(height: 32),
        
        const Text('MOBILE OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black38, letterSpacing: 1)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOtpBox(index, _mobileOtpControllers)),
        ),
        
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleVerifyOtp,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Verify & Finish'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildOtpBox(int index, List<TextEditingController> controllers) {
    return Container(
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: OtrTheme.softShadow,
      ),
      child: TextField(
        controller: controllers[index],
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: OtrTheme.darkNavy),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '', 
          border: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
        },
      ),
    );
  }
}


