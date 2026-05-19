import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/otr_theme.dart';
import '../../widgets/otr_text_field.dart';
import '../../utils/custom_toast.dart';
import '../../services/api_service.dart';

class VendorRegistrationPage extends StatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  State<VendorRegistrationPage> createState() => _VendorRegistrationPageState();
}


class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final ApiService _apiService = ApiService();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers - Step 1: Corporate Identity
  final _legalNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _cinNumberController = TextEditingController();
  final _incorporationDateController = TextEditingController();
  String? _selectedRegType;
  String? _selectedCategory;

  // Controllers - Step 2: Communication & Operations
  final _officeAddressController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _designationController = TextEditingController();
  final _officialEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Controllers - Step 3: Financials & Experience
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  final _turnoverController = TextEditingController();
  final _yearsInBusinessController = TextEditingController();

  // Controllers - Step 4: Banking Details
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _ifscCodeController = TextEditingController();

  // Controllers - Step 5: Compliance & Access
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _ndaWillingness = false;

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        if (_legalNameController.text.trim().isEmpty) {
          CustomToast.showError(context, 'Legal Company Name is required');
          return false;
        }
        if (_selectedRegType == null) {
          CustomToast.showError(context, 'Registration Type is required');
          return false;
        }
        if (_cinNumberController.text.trim().isEmpty) {
          CustomToast.showError(context, 'CIN Number is required');
          return false;
        }
        if (_incorporationDateController.text.isEmpty) {
          CustomToast.showError(context, 'Incorporation Date is required');
          return false;
        }
        if (_selectedCategory == null) {
          CustomToast.showError(context, 'Business Category is required');
          return false;
        }
        return true;
      case 1:
        if (_officeAddressController.text.trim().isEmpty) {
          CustomToast.showError(context, 'Office Address is required');
          return false;
        }
        if (_contactPersonController.text.trim().isEmpty) {
          CustomToast.showError(context, 'Contact Person is required');
          return false;
        }
        if (_designationController.text.trim().isEmpty) {
          CustomToast.showError(context, 'Designation is required');
          return false;
        }
        if (_officialEmailController.text.trim().isEmpty) {
          CustomToast.showError(context, 'Official Email is required');
          return false;
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(_officialEmailController.text.trim())) {
          CustomToast.showError(context, 'Invalid email format');
          return false;
        }
        if (_contactPhoneController.text.trim().isEmpty) {
          CustomToast.showError(context, 'Contact Phone is required');
          return false;
        }
        if (_contactPhoneController.text.trim().length < 10) {
          CustomToast.showError(context, 'Phone number must be at least 10 digits');
          return false;
        }
        return true;
      case 2:
        if (_gstinController.text.trim().isEmpty) {
          CustomToast.showError(context, 'GSTIN is required');
          return false;
        }
        final gstinRegex = RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}Z[A-Z\d]{1}$');
        if (!gstinRegex.hasMatch(_gstinController.text.trim().toUpperCase())) {
          CustomToast.showError(context, 'Invalid GSTIN format (e.g., 22AAAAA0000A1Z5)');
          return false;
        }
        if (_panController.text.trim().isEmpty) {
          CustomToast.showError(context, 'PAN is required');
          return false;
        }
        final panRegex = RegExp(r'^[A-Z]{5}\d{4}[A-Z]{1}$');
        if (!panRegex.hasMatch(_panController.text.trim().toUpperCase())) {
          CustomToast.showError(context, 'Invalid PAN format (e.g., AAAAA9999A)');
          return false;
        }
        if (_turnoverController.text.trim().isEmpty) {
          CustomToast.showError(context, 'Annual Turnover is required');
          return false;
        }
        return true;
      case 3:
        if (_accountNumberController.text.trim().isEmpty) {
          CustomToast.showError(context, 'Account Number is required');
          return false;
        }
        if (_bankNameController.text.trim().isEmpty) {
          CustomToast.showError(context, 'Bank Name is required');
          return false;
        }
        if (_ifscCodeController.text.trim().isEmpty) {
          CustomToast.showError(context, 'IFSC Code is required');
          return false;
        }
        final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
        if (!ifscRegex.hasMatch(_ifscCodeController.text.trim().toUpperCase())) {
          CustomToast.showError(context, 'Invalid IFSC Code format (e.g. SBIN0012345)');
          return false;
        }
        return true;
      case 4:
        if (_passwordController.text.isEmpty) {
          CustomToast.showError(context, 'Password is required');
          return false;
        }
        if (_passwordController.text != _confirmPasswordController.text) {
          CustomToast.showError(context, 'Passwords do not match');
          return false;
        }
        if (!_ndaWillingness) {
          CustomToast.showError(context, 'Please accept the NDA agreement');
          return false;
        }
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_validateStep()) return;

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _handleSubmit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

   Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      // Format Date of Incorporation to ISO8601
      String isoDate = "";
      try {
        final dateParts = _incorporationDateController.text.split('/');
        if (dateParts.length == 3) {
          final dt = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
          isoDate = dt.toUtc().toIso8601String();
        }
      } catch (e) {
        debugPrint("Date parsing error: $e");
      }

      final vendorData = {
        "legalName": _legalNameController.text.trim(),
        "tradeName": _tradeNameController.text.trim(),
        "category": (_selectedCategory ?? "Exam Conducting Agency").toUpperCase().replaceAll(' ', '_'),
        "registrationType": (_selectedRegType ?? "PRIVATE_LIMITED").toUpperCase().replaceAll(' ', '_'),
        "cinNumber": _cinNumberController.text.trim(),
        "dateOfIncorporation": isoDate,
        "registeredAddress": _officeAddressController.text.trim(),
        "officeAddress": _officeAddressController.text.trim(),
        "contactPerson": _contactPersonController.text.trim(),
        "designation": _designationController.text.trim(),
        "contactPhone": _contactPhoneController.text.trim(),
        "contactEmail": _officialEmailController.text.trim(),
        "password": _passwordController.text,
        "website": "https://secureexam.example.com",
        "pan": _panController.text.trim().toUpperCase(),
        "gstin": _gstinController.text.trim().toUpperCase(),
        "annualTurnover": int.tryParse(_turnoverController.text.trim()) ?? 1,
        "yearsInBusiness": int.tryParse(_yearsInBusinessController.text.trim()) ?? 1,
        "accountNumber": _accountNumberController.text.trim(),
        "bankName": _bankNameController.text.trim(),
        "branchName": _branchNameController.text.trim(),
        "ifscCode": _ifscCodeController.text.trim().toUpperCase(),
        "similarProjectsExecuted": 1,
        "infrastructureDetails": "Standard Infrastructure",
        "teamSize": 1,
        "technologyStack": "Standard Stack",
        "certifications": "Standard Certs",
        "documentsSummary": "Pending Upload",
        "ndaWillingness": _ndaWillingness,
      };

      final response = await _apiService.vendorRegister(vendorData);

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: OtrTheme.success, size: 64),
                  SizedBox(height: 16),
                  Text('Registration Successful', textAlign: TextAlign.center),
                ],
              ),
              content: const Text(
                'Your vendor registration request has been submitted for review. Our team will contact you shortly.',
                textAlign: TextAlign.center,
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Back to login
                    },
                    child: const Text('Back to Login'),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          String errorMsg = response['message'] ?? 'Registration failed';
          if (response['data'] != null && response['data']['errors'] != null) {
            final errors = response['data']['errors'] as List;
            if (errors.isNotEmpty) {
              errorMsg = errors.map((e) => "${e['field']}: ${e['message']}").join('\n');
            }
          }
          CustomToast.showError(context, errorMsg);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomToast.showError(context, 'An error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepper(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStepContent(),
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: _prevStep,
          ),
          const Expanded(
            child: Text(
              'Vendor Registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: OtrTheme.darkNavy,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 60),
      child: Stack(
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
            children: List.generate(5, (index) {
              bool isActive = index == _currentStep;
              bool isCompleted = index < _currentStep;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted || isActive ? OtrTheme.primaryBlue : OtrTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted || isActive ? OtrTheme.primaryBlue : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isActive ? OtrTheme.intenseShadow : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : Colors.grey.shade400,
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCompanyDetails();
      case 1:
        return _buildContactInformation();
      case 2:
        return _buildBusinessFinancials();
      case 3:
        return _buildBankingDetails();
      case 4:
        return _buildTechnicalCapabilities();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  Widget _buildCompanyDetails() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepTitle('Corporate Identity', 'JadeEdu Integrated Vendor Management System (IVMS)'),
        OtrTextField(
          label: 'Legal Company Name',
          hintText: 'e.g. Acme Services Pvt Ltd',
          controller: _legalNameController,
          icon: Icons.business_rounded,
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Trade Name',
          hintText: 'Brand name (if any)',
          controller: _tradeNameController,
          icon: Icons.branding_watermark_rounded,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
        ),
        const SizedBox(height: 20),
        _buildLabel('Registration Type', true),
        const SizedBox(height: 10),
        _buildDropdown(
          value: _selectedRegType,
          hint: 'Select Registration Type',
          icon: Icons.account_balance_rounded,
          items: ['Private Limited', 'Public Limited', 'Partnership', 'Proprietorship', 'LLP'],
          onChanged: (val) => setState(() => _selectedRegType = val),
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'CIN Number',
          hintText: 'Corporate Identity Number',
          controller: _cinNumberController,
          icon: Icons.numbers_rounded,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          ],
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Incorporation Date',
          hintText: 'Select Date',
          controller: _incorporationDateController,
          icon: Icons.calendar_today_rounded,
          isRequired: true,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: OtrTheme.primaryBlue,
                      onPrimary: Colors.white,
                      onSurface: OtrTheme.darkNavy,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                _incorporationDateController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
              });
            }
          },
        ),
        const SizedBox(height: 20),
        _buildLabel('Business Category', true),
        const SizedBox(height: 10),
        _buildDropdown(
          value: _selectedCategory,
          hint: 'Select Category',
          icon: Icons.category_rounded,
          items: ['Exam Conducting Agency', 'Software Provider', 'Content Developer', 'Logistics Partner'],
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ],
    );
  }

  Widget _buildContactInformation() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepTitle('Communication & Operations', 'JadeEdu Integrated Vendor Management System (IVMS)'),
        OtrTextField(
          label: 'Registered Office Address',
          hintText: 'Enter full office address',
          controller: _officeAddressController,
          icon: Icons.apartment_rounded,
          maxLines: 2,
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
          ],
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Contact Person',
          hintText: 'Name',
          controller: _contactPersonController,
          icon: Icons.person_rounded,
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Designation',
          hintText: 'Designation',
          controller: _designationController,
          icon: Icons.work_outline_rounded,
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Official Email',
          hintText: 'email@example.com',
          controller: _officialEmailController,
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Contact Phone',
          hintText: 'Phone number',
          controller: _contactPhoneController,
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          maxLength: 10,
        ),
      ],
    );
  }

  Widget _buildBusinessFinancials() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepTitle('Financials & Experience', 'JadeEdu Integrated Vendor Management System (IVMS)'),
        OtrTextField(
          label: 'GSTIN',
          hintText: 'e.g. 22AAAAA0000A1Z5',
          controller: _gstinController,
          icon: Icons.receipt_long_rounded,
          isRequired: true,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          maxLength: 15,
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'PAN',
          hintText: 'e.g. AAAAA9999A',
          controller: _panController,
          icon: Icons.badge_rounded,
          isRequired: true,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          maxLength: 10,
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Annual Turnover (INR)',
          hintText: '0',
          controller: _turnoverController,
          icon: Icons.payments_rounded,
          keyboardType: TextInputType.number,
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Years in Business',
          hintText: '0',
          controller: _yearsInBusinessController,
          icon: Icons.timeline_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ],
    );
  }

  Widget _buildBankingDetails() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepTitle('Banking Information', 'JadeEdu Integrated Vendor Management System (IVMS)'),
        OtrTextField(
          label: 'Account Number',
          hintText: 'Enter bank account number',
          controller: _accountNumberController,
          icon: Icons.account_balance_wallet_rounded,
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Bank Name',
          hintText: 'e.g. State Bank of India',
          controller: _bankNameController,
          icon: Icons.account_balance_rounded,
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Branch Name',
          hintText: 'Branch location',
          controller: _branchNameController,
          icon: Icons.location_on_rounded,
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'IFSC Code',
          hintText: 'e.g. SBIN0012345',
          controller: _ifscCodeController,
          icon: Icons.code_rounded,
          isRequired: true,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          maxLength: 11,
        ),
      ],
    );
  }

  Widget _buildTechnicalCapabilities() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepTitle('Compliance & Access', 'JadeEdu Integrated Vendor Management System (IVMS)'),
        OtrTextField(
          label: 'Create Password',
          hintText: 'Password',
          controller: _passwordController,
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        OtrTextField(
          label: 'Confirm Password',
          hintText: 'Confirm Password',
          controller: _confirmPasswordController,
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          isRequired: true,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: OtrTheme.lightBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OtrTheme.lightBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _ndaWillingness,
                onChanged: (val) => setState(() => _ndaWillingness = val ?? false),
                activeColor: OtrTheme.primaryBlue,
              ),
              const Expanded(
                child: Text(
                  'I AM WILLING TO SIGN A NON-DISCLOSURE AGREEMENT (NDA) FOR GOVERNMENT PROJECTS AND AGREE TO THE PORTAL TERMS.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: OtrTheme.darkNavy,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: OtrTheme.darkNavy,
            letterSpacing: -0.2,
            fontFamily: 'Inter',
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: OtrTheme.softShadow,
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          color: OtrTheme.darkNavy,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: OtrTheme.primaryBlue, size: 22),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('PREVIOUS'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_currentStep == 3 ? 'FINISH' : 'CONTINUE'),
            ),
          ),
        ],
      ),
    );
  }
}
