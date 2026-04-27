import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'address_page.dart';
import '../theme/otr_theme.dart';
import '../widgets/otr_text_field.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class BioPage extends StatefulWidget {
  const BioPage({super.key});

  @override
  State<BioPage> createState() => _BioPageState();
}

class _BioPageState extends State<BioPage> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  int _expandedIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _selectedTitle;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherController = TextEditingController();
  final TextEditingController _motherController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _idProofNumberController =
      TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _tenthBoardController = TextEditingController();
  final TextEditingController _tenthYearController = TextEditingController();
  final TextEditingController _twelfthBoardController = TextEditingController();
  final TextEditingController _twelfthYearController = TextEditingController();

  // Social Category Details
  final TextEditingController _disabilityTypeController =
      TextEditingController();
  final TextEditingController _disabilityPercentController =
      TextEditingController();
  final TextEditingController _sportsNameController = TextEditingController();
  final TextEditingController _sportsLevelController = TextEditingController();
  final TextEditingController _sportsYearController = TextEditingController();
  final TextEditingController _sportsAuthController = TextEditingController();
  final TextEditingController _widowCertController = TextEditingController();
  final TextEditingController _widowDateController = TextEditingController();
  final TextEditingController _widowAuthController = TextEditingController();
  final TextEditingController _exSoldierFromController =
      TextEditingController();
  final TextEditingController _exSoldierToController = TextEditingController();
  final TextEditingController _exSoldierIdController = TextEditingController();
  final TextEditingController _exSoldierCatController = TextEditingController();
  final TextEditingController _govtJoinDateController = TextEditingController();
  final TextEditingController _govtDeptController = TextEditingController();

  String? _selectedGender;
  String? _selectedCommunity;
  String? _selectedNationality;
  String? _selectedQualification;
  String? _selectedMaritalStatus;
  String? _selectedIdProofType;
  DateTime? _selectedDate;

  bool _isPhysicallyDisabled = false;
  bool _isSportsPerson = false;
  bool _isWidow = false;
  bool _isExSoldier = false;
  bool _isGovtEmployee = false;

  // Media
  File? _photoFile;
  File? _signatureFile;
  String? _remotePhotoUrl;
  String? _remoteSignatureUrl;

  // Language Proficiency
  bool _engRead = false, _engWrite = false, _engSpeak = false;
  bool _hinRead = false, _hinWrite = false, _hinSpeak = false;
  bool _gujRead = false, _gujWrite = false, _gujSpeak = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _firstNameController.addListener(_updateFullName);
    _surnameController.addListener(_updateFullName);
  }

  void _updateFullName() {
    setState(() {
      _nameController.text =
          '${_firstNameController.text} ${_surnameController.text}'.trim();
    });
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_updateFullName);
    _surnameController.removeListener(_updateFullName);
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await _apiService.getProfile();
      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          _selectedTitle = data['title'];
          _firstNameController.text = data['firstName'] ?? '';
          _surnameController.text = data['surname'] ?? '';
          _nameController.text = data['fullName'] ?? '';
          _fatherController.text = data['fatherName'] ?? '';
          _motherController.text = data['motherName'] ?? '';
          _mobileController.text = data['mobileNumber'] ?? '';
          _emailController.text = data['email'] ?? '';
          _aadhaarController.text = data['aadhaarNumber'] ?? '';
          _idProofNumberController.text = data['idProofNumber'] ?? '';
          _subCategoryController.text = data['subCategory'] ?? '';
          _tenthBoardController.text = data['tenthBoardName'] ?? '';
          _tenthYearController.text =
              data['tenthPassingYear']?.toString() ?? '';
          _twelfthBoardController.text = data['twelfthBoardName'] ?? '';
          _twelfthYearController.text =
              data['twelfthPassingYear']?.toString() ?? '';

          _selectedGender = data['gender'];
          _selectedCommunity = data['category'];
          _selectedNationality = data['nationality'] ?? 'Indian';
          _selectedQualification = data['highestQualification'];
          _selectedMaritalStatus = data['maritalStatus'];
          _selectedIdProofType = data['idProofType'];

          _isPhysicallyDisabled = data['isPhysicallyDisabled'] ?? false;
          _isSportsPerson = data['isSportsPerson'] ?? false;
          _isWidow = data['isWidow'] ?? false;
          _isExSoldier = data['isExSoldier'] ?? false;
          _isGovtEmployee = data['isGovtEmployee'] ?? false;

          // Social Details
          _disabilityTypeController.text = data['disabilityType'] ?? '';
          _disabilityPercentController.text =
              data['disabilityPercentage']?.toString() ?? '';
          _sportsNameController.text = data['sportsName'] ?? '';
          _sportsLevelController.text = data['sportsLevel'] ?? '';
          _sportsYearController.text =
              data['sportsPassingYear']?.toString() ?? '';
          _sportsAuthController.text = data['sportsAuthority'] ?? '';
          _widowCertController.text = data['widowCertificateNo'] ?? '';
          _widowDateController.text = data['widowCertificateDate'] ?? '';
          _widowAuthController.text = data['widowAuthority'] ?? '';
          _exSoldierFromController.text = data['exSoldierServiceFrom'] ?? '';
          _exSoldierToController.text = data['exSoldierServiceTo'] ?? '';
          _exSoldierIdController.text = data['exSoldierIdCardNo'] ?? '';
          _exSoldierCatController.text = data['exSoldierCategory'] ?? '';
          _govtJoinDateController.text = data['govtServiceJoinDate'] ?? '';
          _govtDeptController.text = data['govtDeptName'] ?? '';

          // Languages
          if (data['englishProficiency'] != null) {
            _engRead = data['englishProficiency']['read'] ?? false;
            _engWrite = data['englishProficiency']['write'] ?? false;
            _engSpeak = data['englishProficiency']['speak'] ?? false;
          }
          if (data['hindiProficiency'] != null) {
            _hinRead = data['hindiProficiency']['read'] ?? false;
            _hinWrite = data['hindiProficiency']['write'] ?? false;
            _hinSpeak = data['hindiProficiency']['speak'] ?? false;
          }
          if (data['gujaratiProficiency'] != null) {
            _gujRead = data['gujaratiProficiency']['read'] ?? false;
            _gujWrite = data['gujaratiProficiency']['write'] ?? false;
            _gujSpeak = data['gujaratiProficiency']['speak'] ?? false;
          }

          if (data['dateOfBirth'] != null) {
            _selectedDate = DateTime.parse(data['dateOfBirth']);
          }

          // Handle remote images
          if (data['photoUrl'] != null) {
            _remotePhotoUrl = data['photoUrl'].startsWith('http')
                ? data['photoUrl']
                : '${ApiConstants.baseUrl}${data['photoUrl']}';
          }
          if (data['signatureUrl'] != null) {
            _remoteSignatureUrl = data['signatureUrl'].startsWith('http')
                ? data['signatureUrl']
                : '${ApiConstants.baseUrl}${data['signatureUrl']}';
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    // Validation based on Backend OTRProfileUpdateSchema

    // 1. Age Validation (18 to 65)
    if (_selectedDate != null) {
      final now = DateTime.now();
      int age = now.year - _selectedDate!.year;
      if (now.month < _selectedDate!.month ||
          (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) {
        age--;
      }
      if (age < 18 || age > 65) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidate must be between 18 and 65 years old'),
          ),
        );
        return;
      }
    }

    // 2. Aadhaar Validation (12 digits)
    final aadhaar = _aadhaarController.text;
    if (aadhaar.isNotEmpty && !RegExp(r'^\d{12}$').hasMatch(aadhaar)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Aadhaar number (must be 12 digits)'),
        ),
      );
      return;
    }

    // 3. Disability Percentage Validation (0-100)
    if (_isPhysicallyDisabled) {
      final percent = int.tryParse(_disabilityPercentController.text);
      if (percent == null || percent < 0 || percent > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disability percentage must be between 0 and 100'),
          ),
        );
        return;
      }
    }

    // 4. Educational Years Validation (1980 to current year)
    final currentYear = DateTime.now().year;
    final tenthYear = int.tryParse(_tenthYearController.text);
    final twelfthYear = int.tryParse(_twelfthYearController.text);

    if (tenthYear != null && (tenthYear < 1980 || tenthYear > currentYear)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '10th passing year must be between 1980 and $currentYear',
          ),
        ),
      );
      return;
    }
    if (twelfthYear != null &&
        (twelfthYear < 1980 || twelfthYear > currentYear)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '12th passing year must be between 1980 and $currentYear',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final profileData = {
        'title': _selectedTitle,
        'firstName': _firstNameController.text,
        'surname': _surnameController.text,
        'fullName': '${_firstNameController.text} ${_surnameController.text}'
            .trim(),
        'fatherName': _fatherController.text,
        'motherName': _motherController.text,
        'gender': _selectedGender,
        'dateOfBirth': _selectedDate?.toIso8601String(),
        'maritalStatus': _selectedMaritalStatus,
        'idProofType': _selectedIdProofType,
        'idProofNumber': _idProofNumberController.text,
        'aadhaarNumber': _aadhaarController.text,
        'category': _selectedCommunity,
        'subCategory': _subCategoryController.text,
        'isPhysicallyDisabled': _isPhysicallyDisabled,
        'nationality': _selectedNationality,
        'isSportsPerson': _isSportsPerson,
        'isWidow': _isWidow,
        'isExSoldier': _isExSoldier,
        'isGovtEmployee': _isGovtEmployee,
        'englishProficiency': {
          'read': _engRead,
          'write': _engWrite,
          'speak': _engSpeak,
        },
        'hindiProficiency': {
          'read': _hinRead,
          'write': _hinWrite,
          'speak': _hinSpeak,
        },
        'gujaratiProficiency': {
          'read': _gujRead,
          'write': _gujWrite,
          'speak': _gujSpeak,
        },
        'highestQualification': _selectedQualification,
        'tenthBoardName': _tenthBoardController.text,
        'tenthPassingYear': int.tryParse(_tenthYearController.text),
        'twelfthBoardName': _twelfthBoardController.text,
        'twelfthPassingYear': int.tryParse(_twelfthYearController.text),

        // Social Details
        'disabilityType': _isPhysicallyDisabled
            ? _disabilityTypeController.text
            : null,
        'disabilityPercentage': _isPhysicallyDisabled
            ? int.tryParse(_disabilityPercentController.text)
            : null,
        'sportsName': _isSportsPerson ? _sportsNameController.text : null,
        'sportsLevel': _isSportsPerson ? _sportsLevelController.text : null,
        'sportsPassingYear': _isSportsPerson
            ? int.tryParse(_sportsYearController.text)
            : null,
        'sportsAuthority': _isSportsPerson ? _sportsAuthController.text : null,
        'widowCertificateNo': _isWidow ? _widowCertController.text : null,
        'widowCertificateDate': _isWidow ? _widowDateController.text : null,
        'widowAuthority': _isWidow ? _widowAuthController.text : null,
        'exSoldierServiceFrom': _isExSoldier
            ? _exSoldierFromController.text
            : null,
        'exSoldierServiceTo': _isExSoldier ? _exSoldierToController.text : null,
        'exSoldierIdCardNo': _isExSoldier ? _exSoldierIdController.text : null,
        'exSoldierCategory': _isExSoldier ? _exSoldierCatController.text : null,
        'govtServiceJoinDate': _isGovtEmployee
            ? _govtJoinDateController.text
            : null,
        'govtDeptName': _isGovtEmployee ? _govtDeptController.text : null,
      };

      final result = await _apiService.updateProfile(profileData);
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddressPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Update failed')),
          );
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage(bool isPhoto) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      final file = File(image.path);
      setState(() {
        if (isPhoto)
          _photoFile = file;
        else
          _signatureFile = file;
      });

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading ${isPhoto ? 'photo' : 'signature'}...'),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      try {
        final result = isPhoto
            ? await _apiService.uploadPhoto(file)
            : await _apiService.uploadSignature(file);

        if (mounted) {
          if (result['success'] == true) {
            // Update the remote URL if the server returned it
            if (result['data'] != null && result['data']['photoUrl'] != null) {
              setState(() {
                final url = result['data']['photoUrl'];
                if (isPhoto) {
                  _remotePhotoUrl = url.startsWith('http')
                      ? url
                      : '${ApiConstants.baseUrl}$url';
                } else if (result['data']['signatureUrl'] != null) {
                  final sigUrl = result['data']['signatureUrl'];
                  _remoteSignatureUrl = sigUrl.startsWith('http')
                      ? sigUrl
                      : '${ApiConstants.baseUrl}$sigUrl';
                }
              });
            } else if (!isPhoto &&
                result['data'] != null &&
                result['data']['signatureUrl'] != null) {
              setState(() {
                final sigUrl = result['data']['signatureUrl'];
                _remoteSignatureUrl = sigUrl.startsWith('http')
                    ? sigUrl
                    : '${ApiConstants.baseUrl}$sigUrl';
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${isPhoto ? 'Photo' : 'Signature'} uploaded successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Upload failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _getFormattedDate() {
    if (_selectedDate == null) return 'DD/MM/YYYY';
    return DateFormat('dd/MM/yyyy').format(_selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Personal Bio',
          style: TextStyle(
            color: OtrTheme.darkNavy,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
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
      body: _isLoading
          ? const Center(child: SpinKitRing(color: OtrTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressTracker(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    'Candidate Profile',
                    'Complete your personal and social details',
                  ),
                  const SizedBox(height: 24),
                        _buildMediaUploadSection(),
                        const SizedBox(height: 16),
                        _buildCollapsibleSection(
                          index: 0,
                          title: 'Basic Information',
                          icon: Icons.person_pin_rounded,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildFunctionalDropdown(
                                    label: 'Title',
                                    hint: 'Mr.',
                                    icon: Icons.title_rounded,
                                    value: _selectedTitle,
                                    items: ['Mr.', 'Ms.', 'Mrs.', 'Dr.'],
                                    onChanged: (val) =>
                                        setState(() => _selectedTitle = val),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: OtrTextField(
                                    label: 'Surname',
                                    hintText: 'Surname',
                                    icon: Icons.person_outline_rounded,
                                    controller: _surnameController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            OtrTextField(
                              label: 'First Name',
                              hintText: 'Enter first name',
                              icon: Icons.person_rounded,
                              controller: _firstNameController,
                            ),
                            const SizedBox(height: 20),
                            OtrTextField(
                              label: 'Full Name',
                              hintText: 'Auto-generated',
                              icon: Icons.badge_rounded,
                              controller: _nameController,
                              enabled: false,
                            ),
                            const SizedBox(height: 20),
                            OtrTextField(
                              label: 'Father\'s Name',
                              hintText: 'Father\'s Name',
                              icon: Icons.person_add_rounded,
                              controller: _fatherController,
                            ),
                            const SizedBox(height: 20),
                            OtrTextField(
                              label: 'Mother\'s Name',
                              hintText: 'Mother\'s Name',
                              icon: Icons.person_add_rounded,
                              controller: _motherController,
                            ),
                          ],
                        ),
                        _buildCollapsibleSection(
                          index: 1,
                          title: 'Identity & Authentication',
                          icon: Icons.shield_rounded,
                          children: [
                            _buildFunctionalDropdown(
                              label: 'ID Proof Type',
                              hint: 'Select ID Type',
                              icon: Icons.badge,
                              value: _selectedIdProofType,
                              items: [
                                'Aadhaar Card',
                                'PAN Card',
                                'Voter ID',
                                'Driving License',
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedIdProofType = val),
                            ),
                            const SizedBox(height: 20),
                            OtrTextField(
                              label: 'ID Proof Number',
                              hintText: 'Enter ID number',
                              icon: Icons.tag_rounded,
                              controller: _idProofNumberController,
                            ),
                            const SizedBox(height: 20),
                            OtrTextField(
                              label: 'Aadhaar Number',
                              hintText: '12-digit number',
                              icon: Icons.credit_card_rounded,
                              controller: _aadhaarController,
                            ),
                          ],
                        ),
                        _buildCollapsibleSection(
                          index: 2,
                          title: 'Personal Demographics',
                          icon: Icons.public_rounded,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFunctionalDropdown(
                                    label: 'Gender',
                                    hint: 'Gender',
                                    icon: Icons.transgender_rounded,
                                    value: _selectedGender,
                                    items: ['MALE', 'FEMALE', 'OTHER'],
                                    onChanged: (val) =>
                                        setState(() => _selectedGender = val),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildClickableField(
                                    label: 'Date of Birth',
                                    value: _getFormattedDate(),
                                    icon: Icons.calendar_today_rounded,
                                    onTap: () => _selectDate(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildFunctionalDropdown(
                              label: 'Marital Status',
                              hint: 'Select status',
                              icon: Icons.favorite_rounded,
                              value: _selectedMaritalStatus,
                              items: ['Single', 'Married', 'Divorced', 'Widow'],
                              onChanged: (val) =>
                                  setState(() => _selectedMaritalStatus = val),
                            ),
                            const SizedBox(height: 20),
                            _buildFunctionalDropdown(
                              label: 'Nationality',
                              hint: 'Select nationality',
                              icon: Icons.flag_rounded,
                              value: _selectedNationality,
                              items: ['Indian', 'Other'],
                              onChanged: (val) =>
                                  setState(() => _selectedNationality = val),
                            ),
                          ],
                        ),
                        _buildCollapsibleSection(
                          index: 3,
                          title: 'Educational & Social Status',
                          icon: Icons.school_rounded,
                          children: [
                            _buildFunctionalDropdown(
                              label: 'Highest Qualification',
                              hint: 'Select Highest',
                              icon: Icons.school_rounded,
                              value: _selectedQualification,
                              items: [
                                '10th',
                                '12th',
                                'B.Tech',
                                'B.Sc',
                                'M.Tech',
                                'PhD',
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedQualification = val),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OtrTextField(
                                    label: '10th Board',
                                    hintText: 'Education Board',
                                    icon: Icons.history_edu_rounded,
                                    controller: _tenthBoardController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OtrTextField(
                                    label: 'Year',
                                    hintText: '2010',
                                    icon: Icons.calendar_today,
                                    controller: _tenthYearController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OtrTextField(
                                    label: '12th Board',
                                    hintText: 'Education Board',
                                    icon: Icons.history_edu_rounded,
                                    controller: _twelfthBoardController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OtrTextField(
                                    label: 'Year',
                                    hintText: '2012',
                                    icon: Icons.calendar_today,
                                    controller: _twelfthYearController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFunctionalDropdown(
                                    label: 'Category',
                                    hint: 'Category',
                                    icon: Icons.groups_rounded,
                                    value: _selectedCommunity,
                                    items: ['UR', 'SC', 'ST', 'OBC', 'EWS'],
                                    onChanged: (val) => setState(
                                      () => _selectedCommunity = val,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OtrTextField(
                                    label: 'Sub Category',
                                    hintText: 'Sub-category',
                                    icon: Icons.category_rounded,
                                    controller: _subCategoryController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSwitchTile(
                              'Physically Disabled',
                              _isPhysicallyDisabled,
                              (val) =>
                                  setState(() => _isPhysicallyDisabled = val),
                            ),
                            if (_isPhysicallyDisabled) ...[
                              OtrTextField(
                                label: 'Disability Type',
                                hintText: 'Type',
                                icon: Icons.accessibility_new_rounded,
                                controller: _disabilityTypeController,
                              ),
                              const SizedBox(height: 12),
                              OtrTextField(
                                label: 'Percentage (%)',
                                hintText: '40',
                                icon: Icons.percent_rounded,
                                controller: _disabilityPercentController,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                            _buildSwitchTile(
                              'Sports Person',
                              _isSportsPerson,
                              (val) => setState(() => _isSportsPerson = val),
                            ),
                            if (_isSportsPerson) ...[
                              OtrTextField(
                                label: 'Sports Name',
                                hintText: 'Name',
                                icon: Icons.emoji_events_rounded,
                                controller: _sportsNameController,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OtrTextField(
                                      label: 'Level',
                                      hintText: 'State/Nat.',
                                      icon: Icons.leaderboard_rounded,
                                      controller: _sportsLevelController,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OtrTextField(
                                      label: 'Year',
                                      hintText: '2020',
                                      icon: Icons.calendar_today,
                                      controller: _sportsYearController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              OtrTextField(
                                label: 'Authority',
                                hintText: 'Issuing Org',
                                icon: Icons.account_balance_rounded,
                                controller: _sportsAuthController,
                              ),
                            ],
                            _buildSwitchTile(
                              'Widow Person',
                              _isWidow,
                              (val) => setState(() => _isWidow = val),
                            ),
                            if (_isWidow) ...[
                              OtrTextField(
                                label: 'Certificate No.',
                                hintText: 'Number',
                                icon: Icons.description_rounded,
                                controller: _widowCertController,
                              ),
                              const SizedBox(height: 12),
                              _buildClickableField(
                                label: 'Certificate Date',
                                value: _widowDateController.text.isEmpty
                                    ? 'Select Date'
                                    : _widowDateController.text,
                                icon: Icons.calendar_month_rounded,
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime.now(),
                                  );
                                  if (d != null)
                                    setState(
                                      () => _widowDateController.text =
                                          DateFormat('yyyy-MM-dd').format(d),
                                    );
                                },
                              ),
                            ],
                            _buildSwitchTile(
                              'Ex-Soldier',
                              _isExSoldier,
                              (val) => setState(() => _isExSoldier = val),
                            ),
                            if (_isExSoldier) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OtrTextField(
                                      label: 'Service From',
                                      hintText: '2010',
                                      icon: Icons.login_rounded,
                                      controller: _exSoldierFromController,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OtrTextField(
                                      label: 'Service To',
                                      hintText: '2020',
                                      icon: Icons.logout_rounded,
                                      controller: _exSoldierToController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              OtrTextField(
                                label: 'ID Card No.',
                                hintText: 'Number',
                                icon: Icons.badge_rounded,
                                controller: _exSoldierIdController,
                              ),
                            ],
                            _buildSwitchTile(
                              'Govt Employee',
                              _isGovtEmployee,
                              (val) => setState(() => _isGovtEmployee = val),
                            ),
                            if (_isGovtEmployee) ...[
                              OtrTextField(
                                label: 'Dept Name',
                                hintText: 'Department',
                                icon: Icons.business_rounded,
                                controller: _govtDeptController,
                              ),
                              const SizedBox(height: 12),
                              _buildClickableField(
                                label: 'Join Date',
                                value: _govtJoinDateController.text.isEmpty
                                    ? 'Select Date'
                                    : _govtJoinDateController.text,
                                icon: Icons.calendar_month_rounded,
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime.now(),
                                  );
                                  if (d != null)
                                    setState(
                                      () => _govtJoinDateController.text =
                                          DateFormat('yyyy-MM-dd').format(d),
                                    );
                                },
                              ),
                            ],
                          ],
                        ),
                        _buildCollapsibleSection(
                          index: 4,
                          title: 'Language Proficiency',
                          icon: Icons.translate_rounded,
                          children: [
                            _buildLanguageCard(
                              'English',
                              _engRead,
                              _engWrite,
                              _engSpeak,
                              (r, w, s) => setState(() {
                                _engRead = r;
                                _engWrite = w;
                                _engSpeak = s;
                              }),
                            ),
                            const SizedBox(height: 12),
                            _buildLanguageCard(
                              'Hindi',
                              _hinRead,
                              _hinWrite,
                              _hinSpeak,
                              (r, w, s) => setState(() {
                                _hinRead = r;
                                _hinWrite = w;
                                _hinSpeak = s;
                              }),
                            ),
                            const SizedBox(height: 12),
                            _buildLanguageCard(
                              'Gujarati',
                              _gujRead,
                              _gujWrite,
                              _gujSpeak,
                              (r, w, s) => setState(() {
                                _gujRead = r;
                                _gujWrite = w;
                                _gujSpeak = s;
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildSaveButton(),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
    );
  }

  Widget _buildProgressTracker() {
    return Row(
      children: [
        _buildStepIndicator('1', 'Bio', true),
        _buildStepLine(false),
        _buildStepIndicator('2', 'Address', false),
        _buildStepLine(false),
        _buildStepIndicator('3', 'Docs', false),
      ],
    );
  }

  Widget _buildStepIndicator(String step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? OtrTheme.primaryBlue
                : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: OtrTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? OtrTheme.primaryBlue : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14, left: 4, right: 4),
        color: isDone ? OtrTheme.primaryBlue : Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: OtrTheme.darkNavy,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: OtrTheme.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: OtrTheme.primaryBlue.withOpacity(0.4),
      ),
      child: _isSaving
          ? const SpinKitThreeBounce(color: Colors.white, size: 20)
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SAVE & PROCEED',
                  style: TextStyle(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
    );
  }

  Widget _buildCollapsibleSection({
    required int index,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    bool isExpanded = _expandedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? OtrTheme.primaryBlue.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isExpanded
              ? OtrTheme.primaryBlue.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: index == 0,
          onExpansionChanged: (expanded) =>
              setState(() => _expandedIndex = expanded ? index : -1),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isExpanded ? OtrTheme.primaryBlue : OtrTheme.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isExpanded ? Colors.white : OtrTheme.primaryBlue,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isExpanded ? OtrTheme.primaryBlue : OtrTheme.darkNavy,
              fontSize: 15,
            ),
          ),
          trailing: Icon(
            isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: isExpanded ? OtrTheme.primaryBlue : Colors.grey,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: OtrTheme.darkNavy,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: OtrTheme.softShadow,
            ),
            child: Row(
              children: [
                Icon(icon, color: OtrTheme.primaryBlue, size: 22),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: value == 'DD/MM/YYYY'
                        ? Colors.grey.shade400
                        : OtrTheme.darkNavy,
                    fontWeight: value == 'DD/MM/YYYY'
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionalDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: OtrTheme.darkNavy,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: OtrTheme.softShadow,
          ),
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: OtrTheme.primaryBlue, size: 22),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            hint: Text(
              hint,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: OtrTheme.darkNavy,
              fontWeight: FontWeight.w600,
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            iconSize: 24,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard(
    String language,
    bool read,
    bool write,
    bool speak,
    Function(bool, bool, bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OtrTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: OtrTheme.darkNavy,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProficiencyChip(
                'Read',
                read,
                (val) => onChanged(val, write, speak),
              ),
              _buildProficiencyChip(
                'Write',
                write,
                (val) => onChanged(read, val, speak),
              ),
              _buildProficiencyChip(
                'Speak',
                speak,
                (val) => onChanged(read, write, val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProficiencyChip(
    String label,
    bool isSelected,
    ValueChanged<bool> onTap,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: onTap,
      selectedColor: OtrTheme.primaryBlue.withOpacity(0.1),
      checkmarkColor: OtrTheme.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(
        color: isSelected ? OtrTheme.primaryBlue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: OtrTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OtrTheme.darkNavy,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: OtrTheme.primaryBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
      ),
    );
  }

  Widget _buildMediaUploadSection() {
    return Row(
      children: [
        Expanded(
          child: _buildMediaCard(
            'Photo',
            _photoFile,
            _remotePhotoUrl,
            Icons.camera_alt_rounded,
            () => _pickImage(true),
            () => _handleDelete(true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMediaCard(
            'Signature',
            _signatureFile,
            _remoteSignatureUrl,
            Icons.edit_note_rounded,
            () => _pickImage(false),
            () => _handleDelete(false),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDelete(bool isPhoto) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${isPhoto ? 'Photo' : 'Signature'}?'),
        content: const Text('Are you sure you want to permanently remove this image?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final result = isPhoto 
            ? await _apiService.deletePhoto() 
            : await _apiService.deleteSignature();
            
        if (mounted) {
          if (result['success'] == true) {
            setState(() {
              if (isPhoto) {
                _photoFile = null;
                _remotePhotoUrl = null;
              } else {
                _signatureFile = null;
                _remoteSignatureUrl = null;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${isPhoto ? 'Photo' : 'Signature'} deleted successfully'), backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Delete failed'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMediaCard(
    String label,
    File? file,
    String? remoteUrl,
    IconData icon,
    VoidCallback onTap,
    VoidCallback onDelete,
  ) {
    bool hasMedia = file != null || remoteUrl != null;
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: OtrTheme.primaryBlue.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  if (file != null)
                    Image.file(
                      file,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else if (remoteUrl != null)
                    Image.network(
                      remoteUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildUploadPlaceholder(label, icon, true),
                    )
                  else
                    _buildUploadPlaceholder(label, icon, false),
                  if (hasMedia)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasMedia)
          Positioned(
            top: -5,
            left: -5,
            child: IconButton(
              onPressed: onDelete,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade700, size: 18),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadPlaceholder(String label, IconData icon, bool isError) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OtrTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isError ? Icons.error_outline_rounded : icon,
              color: isError ? Colors.red : OtrTheme.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: OtrTheme.darkNavy,
              fontSize: 13,
            ),
          ),
          Text(
            isError ? 'Reload Required' : 'Upload',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
