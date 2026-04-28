import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/custom_toast.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final ApiService _apiService = ApiService();
  String _selectedMethod = 'UPI';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String? appUuid = args?['applicationUuid'];
    final String title = args?['title'] ?? 'Application Fee';
    final double amount = args?['amount'] ?? 500.0;

    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Online Payment',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildAmountCard(title, amount),
            const SizedBox(height: 32),
            _buildPaymentMethods(),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () => _handlePayment(appUuid, amount),
              style: ElevatedButton.styleFrom(
                backgroundColor: OtrTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isProcessing
                  ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                  : Text(
                      'Pay ₹$amount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(String title, double amount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [OtrTheme.primaryBlue, OtrTheme.darkNavy],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'Payable Amount',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '₹$amount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT PAYMENT METHOD',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 16),
        _buildMethodItem('UPI', Icons.mobile_friendly),
        _buildMethodItem('Card', Icons.credit_card),
        _buildMethodItem('Net Banking', Icons.account_balance),
      ],
    );
  }

  Widget _buildMethodItem(String method, IconData icon) {
    bool isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? OtrTheme.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? OtrTheme.primaryBlue : Colors.grey),
            const SizedBox(width: 16),
            Text(
              method,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? OtrTheme.primaryBlue : OtrTheme.darkNavy,
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? OtrTheme.primaryBlue : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment(String? appUuid, double amount) async {
    if (appUuid == null) return;

    setState(() => _isProcessing = true);

    try {
      // Mocking payment for offline demo
      await Future.delayed(const Duration(seconds: 1));
      final Map<String, dynamic> initResult = {
        'success': true,
        'data': {'paymentUuid': 'mock_payment_uuid'},
      };

      if (initResult['success'] == true) {
        // 2. Simulate Payment Delay
        await Future.delayed(const Duration(seconds: 2));

        // 3. Mock Verification
        final Map<String, dynamic> verifyResult = {
          'success': true,
          'message': 'Payment verified (Offline Mode)',
        };

        if (verifyResult['success'] == true) {
          if (mounted) _showSuccessDialog();
        } else {
          if (mounted)
            CustomToast.showSuccess(context, 
                  verifyResult['message'] as String? ?? 'Verification failed',
                );
        }
      } else {
        if (mounted)
          CustomToast.showSuccess(context, 
                initResult['message'] as String? ?? 'Failed to initiate',
              );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, anim1, anim2) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your application has been submitted.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard',
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OtrTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
