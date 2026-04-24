import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../models/advertisement_model.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class ApplyNowPage extends StatefulWidget {
  const ApplyNowPage({super.key});

  @override
  State<ApplyNowPage> createState() => _ApplyNowPageState();
}

class _ApplyNowPageState extends State<ApplyNowPage> {
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isExiting = false;
  Map<String, dynamic>? _profileData;

  // Step 2 Data
  String? _selectedPost;
  String? _selectedMedium = 'English';
  final List<String?> _centerPriorities = [null, null, null];

  // Step 3 Data (Dummy flags for visualization)
  final Map<String, bool> _uploadedDocs = {
    'Academic': true,
    'Professional': false,
    'Identity': false,
    'Category': false,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchMockData();
  }

  Future<void> _fetchMockData() async {
    try {
      final result = await _apiService.getProfile();
      if (mounted) {
        setState(() {
          if (result['success'] == true) {
            _profileData = result['data'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final advertisement =
        ModalRoute.of(context)!.settings.arguments as Advertisement;

    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'OFFICIAL PERSONNEL INTAKE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: OtrTheme.darkNavy,
              ),
            ),
            Text(
              'DEPARTMENT OF EDUCATION',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCircle(color: OtrTheme.primaryBlue),
            )
          : Column(
              children: [
                _buildStepper(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildEligibilityStep(advertisement),
                      _buildConfigurationStep(),
                      _buildEvidenceStep(),
                      _buildSettlementStep(),
                      _buildSuccessStep(advertisement.uuid),
                    ],
                  ),
                ),
                if (_currentStep < 4) _buildBottomNavbar(),
              ],
            ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          bool isActive = index <= _currentStep;
          bool isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? OtrTheme.primaryBlue
                        : (isActive ? Colors.green : Colors.grey.shade100),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isActive && !isCurrent
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent
                                  ? Colors.white
                                  : Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                if (index < 4)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < _currentStep
                          ? Colors.green
                          : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEligibilityStep(Advertisement adv) {
    final p = _profileData ?? {};
    final String fullName = p['fullName'] ?? 'N/A';
    final String regId = p['registrationId'] ?? 'N/A';
    final String category = p['category'] ?? 'N/A';

    // Calculate Age
    String ageStr = 'N/A';
    if (p['dateOfBirth'] != null) {
      final dob = DateTime.parse(p['dateOfBirth']);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day))
        age--;
      ageStr = '$age Years';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Colors.green),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AUTOMATIC ELIGIBILITY CONFIRMATION',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Credential analysis successful based on your OTR profile.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'PERSONNEL DATA REVIEW',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildDataCard([
            _buildDataRow('LEGAL IDENTITY', fullName),
            _buildDataRow('CANDIDATE ID', regId),
            _buildDataRow('CHRONOLOGICAL AGE', ageStr),
            _buildDataRow('CATEGORY', category),
          ]),
          const SizedBox(height: 32),
          const Text(
            'REQUIRED QUALIFICATIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Text(
              adv.qualifications,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OPERATIONAL PREFERENCES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'PRIMARY POST SELECTION',
            _selectedPost,
            ['Junior Teacher', 'Support Staff', 'Principal'],
            (v) => setState(() => _selectedPost = v),
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'EXAMINATION MEDIUM',
            _selectedMedium,
            ['English', 'Gujarati', 'Hindi'],
            (v) => setState(() => _selectedMedium = v),
          ),
          const SizedBox(height: 32),
          const Text(
            'DEPLOYMENT CENTRES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'PRIORITY 1',
            _centerPriorities[0],
            ['Ahmedabad', 'Surat', 'Rajkot'],
            (v) => setState(() => _centerPriorities[0] = v),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            'PRIORITY 2',
            _centerPriorities[1],
            ['Ahmedabad', 'Surat', 'Rajkot'],
            (v) => setState(() => _centerPriorities[1] = v),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            'PRIORITY 3',
            _centerPriorities[2],
            ['Ahmedabad', 'Surat', 'Rajkot'],
            (v) => setState(() => _centerPriorities[2] = v),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EVIDENCE VAULT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildEvidenceItem(
            'Essential Academic Qualification',
            'Pending Selection',
          ),
          _buildEvidenceItem(
            'Professional Degree/Certification',
            'Verified from OTR',
          ),
          _buildEvidenceItem(
            'Identity & Domicile Verification',
            'Pending Selection',
          ),
          _buildEvidenceItem('Category/Caste Certificate', 'N/A for UR'),
        ],
      ),
    );
  }

  Widget _buildSettlementStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: OtrTheme.primaryBlue,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'APPLICATION SETTLEMENT',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Review and pay the application fee',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(),
                ),
                _buildPaymentRow('Original Fee', '₹1000'),
                _buildPaymentRow('OTR Subsidy', '-₹500'),
                _buildPaymentRow('Processing Fee', '₹0'),
                const Divider(),
                const SizedBox(height: 12),
                _buildPaymentRow('NET PAYABLE', '₹500', isTotal: true),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'SECURE TRANSACTION PROTOCOL',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFinalSubmit(String advUuid) async {
    setState(() => _isExiting = true);
    try {
      final appData = {
        "advertisementUuid": advUuid,
        "postPreference1": _selectedPost ?? 'Position',
        "examCentrePreference1": _centerPriorities[0] ?? 'Ahmedabad',
        "examCentrePreference2": _centerPriorities[1],
        "examCentrePreference3": _centerPriorities[2],
        "examMedium": _selectedMedium,
        "category": _profileData?['category'] ?? 'UR',
        "hasAcceptedTerms": true,
        "hasDeclarationSigned": true,
      };

      final result = await _apiService.submitApplication(appData);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application synchronized successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to dashboard and clear form state
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Final synchronization failed',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExiting = false);
    }
  }

  Widget _buildSuccessStep(String advUuid) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: OtrTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: OtrTheme.primaryBlue,
              size: 64,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'APPLICATION SYNCHRONIZED',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your application for Junior Teacher has been received and verified for initial processing.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 13),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: _buildRefCard('INDEX REFERENCE', 'APP-2026-621', true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRefCard('SETTLEMENT HASH', 'TXN2026E9USQA', false),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _isExiting ? null : () => _handleFinalSubmit(advUuid),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
            ),
            child: _isExiting
                ? const SpinKitThreeBounce(color: Colors.white, size: 24)
                : const Text('RETURN TO COMMAND CENTRE'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text(
              'DOWNLOAD RECORD',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildBottomNavbar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: TextButton(
                onPressed: _prevStep,
                child: const Text(
                  'GO BACK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: Text(
                _currentStep == 3 ? 'PAY & CONTINUE' : 'CONTINUE APPLICATION',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: OtrTheme.darkNavy,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OtrTheme.lightBlue),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text('Select $label', style: const TextStyle(fontSize: 12)),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceItem(String title, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: OtrTheme.darkNavy,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: OtrTheme.lightBlue,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text(
              'UPLOAD',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              color: isTotal ? OtrTheme.darkNavy : Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w900,
              color: isTotal ? OtrTheme.primaryBlue : OtrTheme.darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefCard(String label, String code, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? OtrTheme.darkNavy : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            code,
            style: TextStyle(
              color: isDark ? Colors.white : OtrTheme.darkNavy,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
