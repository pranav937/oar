import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/otr_theme.dart';
import '../widgets/otr_text_field.dart';
import '../services/api_service.dart';
import '../utils/custom_toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'Candidate';
  final ApiService _apiService = ApiService();

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      CustomToast.showError(context, 'Please enter both username and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      debugPrint("DEBUG: Attempting login for role: $_selectedRole");
      
      final Map<String, dynamic> result;
      if (_selectedRole == 'Vendor') {
        result = await _apiService.vendorLogin(
          _usernameController.text,
          _passwordController.text,
        );
      } else {
        result = await _apiService.login(
          _usernameController.text,
          _passwordController.text,
        );
      }

      if (result['success'] == true) {
        if (_selectedRole == 'Vendor') {
          if (mounted) {
            setState(() => _isLoading = false);
            CustomToast.showSuccess(context, 'Vendor Login Successful');
            Navigator.pushReplacementNamed(context, '/vendor-dashboard');
          }
          return;
        }

        if (mounted) {
          setState(() => _isLoading = true); 
        }

        final profileResult = await _apiService.getProfile();

        if (mounted) {
          // Role Validation Logic
          final userRole = profileResult['data']?['role'] ?? 'Candidate'; 
          
          if (_selectedRole != userRole) {
            setState(() => _isLoading = false);
            CustomToast.showError(
              context, 
              'Access Denied: You are trying to login as $_selectedRole with a $userRole account.'
            );
            await _apiService.logout();
            return;
          }

          if (profileResult['success'] == true &&
              profileResult['data'] != null &&
              profileResult['data']['firstName'] != null &&
              profileResult['data']['firstName'].toString().isNotEmpty) {
            // OTR Completed -> Dashboard
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            // OTR Not Completed -> Bio Page
            Navigator.pushReplacementNamed(context, '/bio');
          }
        }
      } else {
        if (mounted) {
          String errorMsg = result['message'] ?? 'Login failed';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showRegistrationOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Join the Network',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: OtrTheme.darkNavy,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select your registration type to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            _buildOptionCard(
              title: 'Candidate',
              subtitle: 'I am looking for recruitment opportunities',
              icon: Icons.person_search_rounded,
              color: OtrTheme.primaryBlue,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/register');
              },
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              title: 'Vendor',
              subtitle: 'I am a service provider or agency',
              icon: Icons.business_center_rounded,
              color: OtrTheme.mediumBlue,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/vendor-register');
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: OtrTheme.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade300,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: OtrTheme.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleButton('Candidate', Icons.person_rounded),
          ),
          Expanded(
            child: _buildRoleButton('Vendor', Icons.business_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(String role, IconData icon) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? OtrTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? OtrTheme.intenseShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.black38,
            ),
            const SizedBox(width: 10),
            Text(
              role,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      body: Stack(
        children: [
          // Background Design Elements
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: OtrTheme.primaryBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: OtrTheme.mediumBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo Section
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: SvgPicture.asset(
                        'assets/images/jadeE.svg',
                        width: 150,
                        height: 75,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OtrTheme.darkNavy,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue to OTR System',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildRoleToggle(),
                  const SizedBox(height: 40),
                  // Form
                  OtrTextField(
                    label: 'Username / Email',
                    hintText: 'Enter your username',
                    icon: Icons.alternate_email_rounded,
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 20),
                  OtrTextField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    icon: Icons.lock_person_outlined,
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/forgot-password',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: OtrTheme.primaryBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
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
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OtrTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
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
                              'LOG IN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showRegistrationOptions,
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                            color: OtrTheme.primaryBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
