import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'address_page.dart';
import '../theme/otr_theme.dart';
import '../widgets/otr_text_field.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/custom_toast.dart';

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

  String? _selectedCategory;
  String? _selectedGender;
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

  // Address fields to preserve during bio update
  String? _savedPresentAddress;
  String? _savedPermanentAddress;
  String? _savedCorrespondenceAddress;
  String? _savedState;
  String? _savedDistrict;
  String? _savedTaluka;
  String? _savedPinCode;

  // Media
  File? _photoFile;
  File? _signatureFile;
  String? _remotePhotoUrl;
  String? _remoteSignatureUrl;
  File? _aadhaarFile;
  String? _remoteAadharUrl;

  // Language Proficiency
  bool _engRead = false, _engWrite = false, _engSpeak = false;
  bool _hinRead = false, _hinWrite = false, _hinSpeak = false;
  bool _gujRead = false, _gujWrite = false, _gujSpeak = false;
  bool _isReadOnly = false;
  bool _isEditingFromProfile = false;

  final Map<String, String> _idProofMapping = {
    'Aadhaar Card': 'AADHAR',
    'PAN Card': 'PAN',
    'Voter ID': 'ELECTION',
    'Driving License': 'DRIVING',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['isEditing'] == true) {
      _isEditingFromProfile = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _firstNameController.addListener(_updateFullName);
    _surnameController.addListener(_updateFullName);
    _aadhaarController.addListener(_syncIdProofWithAadhaar);
  }

  void _syncIdProofWithAadhaar() {
    if (_selectedIdProofType == 'Aadhaar Card') {
      _idProofNumberController.text = _aadhaarController.text;
    }
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
    _aadhaarController.removeListener(_syncIdProofWithAadhaar);
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
          _tenthBoardController.text = data['tenthBoardName'] ?? '';
          _tenthYearController.text =
              data['tenthPassingYear']?.toString() ?? '';
          _twelfthBoardController.text = data['twelfthBoardName'] ?? '';
          _twelfthYearController.text =
              data['twelfthPassingYear']?.toString() ?? '';

          _selectedGender = data['gender'];
          _selectedNationality = data['nationality'] != null
              ? (data['nationality'][0] +
                    data['nationality'].substring(1).toLowerCase())
              : 'Indian';
          _selectedQualification = data['highestQualification'];
          _selectedMaritalStatus = data['maritalStatus'] != null
              ? (data['maritalStatus'][0] +
                    data['maritalStatus'].substring(1).toLowerCase())
              : null;

          // Map ID Proof Type back to display name
          final backendIdType = data['idProofType'];
          _selectedIdProofType = _idProofMapping.entries
              .firstWhere(
                (e) => e.value == backendIdType,
                orElse: () => MapEntry(backendIdType ?? '', ''),
              )
              .key;
          if (_selectedIdProofType!.isEmpty) _selectedIdProofType = null;

          _selectedCategory = data['category'] ?? 'UR';

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

          // Preserve address fields
          _savedPresentAddress = data['presentAddress'];
          _savedPermanentAddress = data['permanentAddress'];
          _savedCorrespondenceAddress = data['correspondenceAddress'];
          _savedState = data['state'];
          _savedDistrict = data['district'];
          _savedTaluka = data['taluka'];
          _savedPinCode = data['pinCode'];
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
            String url = data['photoUrl'];
            if (url.startsWith('http')) {
              _remotePhotoUrl = url;
            } else {
              final String base = ApiConstants.baseUrl.endsWith('/')
                  ? ApiConstants.baseUrl.substring(
                      0,

                      ApiConstants.baseUrl.length - 1,
                    )
                  : ApiConstants.baseUrl;
              final String path = url.startsWith('/') ? url : '/$url';
              _remotePhotoUrl = '$base$path';
            }
          }
          if (data['signatureUrl'] != null) {
            String url = data['signatureUrl'];
            if (url.startsWith('http')) {
              _remoteSignatureUrl = url;
            } else {
              final String base = ApiConstants.baseUrl.endsWith('/')
                  ? ApiConstants.baseUrl.substring(
                      0,
                      ApiConstants.baseUrl.length - 1,
                    )
                  : ApiConstants.baseUrl;
              final String path = url.startsWith('/') ? url : '/$url';
              _remoteSignatureUrl = '$base$path';
            }
          }

          if (_firstNameController.text.isNotEmpty && !_isEditingFromProfile) {
            _isReadOnly = true;
          } else {
            _isReadOnly = false;
          }

          _fetchAadhaarDocument();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchAadhaarDocument() async {
    try {
      final docsResult = await _apiService.getDocuments();
      if (docsResult['success'] == true && docsResult['data'] != null) {
        final List docs = docsResult['data'];
        final aadhaarDoc = docs.firstWhere(
          (doc) => doc['documentType'] == 'AADHAR',
          orElse: () => null,
        );
        if (aadhaarDoc != null) {
          String url = aadhaarDoc['url'] ?? aadhaarDoc['fileUrl'] ?? '';
          if (url.isNotEmpty) {
            setState(() {
              if (url.startsWith('http')) {
                _remoteAadharUrl = url;
              } else {
                final String base = ApiConstants.baseUrl.endsWith('/')
                    ? ApiConstants.baseUrl.substring(
                        0,
                        ApiConstants.baseUrl.length - 1,
                      )
                    : ApiConstants.baseUrl;
                final String path = url.startsWith('/') ? url : '/$url';
                _remoteAadharUrl = '$base$path';
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching Aadhaar document: $e');
    }
  }

  Future<void> _handleSave() async {
    // 1. Mandatory Fields Check (matches backend OTRProfileUpdateSchema)
    if (_firstNameController.text.trim().isEmpty) {
      CustomToast.showError(context, 'First Name is required');
      return;
    }
    if (_surnameController.text.trim().isEmpty) {
      CustomToast.showError(context, 'Surname is required');
      return;
    }
    if (_selectedGender == null) {
      CustomToast.showError(context, 'Gender is required');
      return;
    }
    if (_selectedDate == null) {
      CustomToast.showError(context, 'Date of Birth is required');
      return;
    }
    if (_selectedIdProofType == null) {
      CustomToast.showError(context, 'ID Proof Type is required');
      return;
    }
    if (_idProofNumberController.text.trim().isEmpty) {
      CustomToast.showError(context, 'ID Proof Number is required');
      return;
    }
    if (_aadhaarController.text.trim().isEmpty) {
      CustomToast.showError(context, 'Aadhaar Number is required');
      return;
    }
    if (_selectedCategory == null) {
      CustomToast.showError(context, 'Category is required');
      return;
    }
    if (_selectedQualification == null) {
      CustomToast.showError(context, 'Highest Qualification is required');
      return;
    }
    if (_tenthBoardController.text.trim().isEmpty) {
      CustomToast.showError(context, '10th Board Name is required');
      return;
    }
    if (_twelfthBoardController.text.trim().isEmpty) {
      CustomToast.showError(context, '12th Board Name is required');
      return;
    }

    // 2. Age Validation (18 to 65)
    final now = DateTime.now();
    int age = now.year - _selectedDate!.year;
    if (now.month < _selectedDate!.month ||
        (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) {
      age--;
    }
    if (age < 18 || age > 65) {
      CustomToast.showError(
        context,
        'Candidate must be between 18 and 65 years old',
      );
      return;
    }

    // 3. Aadhaar Validation (exactly 12 digits)
    if (!RegExp(r'^\d{12}$').hasMatch(_aadhaarController.text.trim())) {
      CustomToast.showError(
        context,
        'Aadhaar Number must be exactly 12 digits',
      );
      return;
    }

    // 4. Educational Years Validation (1980 to current year)
    final currentYear = DateTime.now().year;
    final tenthYear = int.tryParse(_tenthYearController.text);
    final twelfthYear = int.tryParse(_twelfthYearController.text);

    if (tenthYear == null || tenthYear < 1980 || tenthYear > currentYear) {
      CustomToast.showError(
        context,
        '10th passing year must be between 1980 and $currentYear',
      );
      return;
    }
    if (twelfthYear == null ||
        twelfthYear < 1980 ||
        twelfthYear > currentYear) {
      CustomToast.showError(
        context,
        '12th passing year must be between 1980 and $currentYear',
      );
      return;
    }

    if (tenthYear == twelfthYear) {
      CustomToast.showError(
        context,
        '10th and 12th passing year cannot be the same',
      );
      return;
    }

    if (tenthYear > twelfthYear) {
      CustomToast.showError(
        context,
        '10th passing year cannot be after 12th passing year',
      );
      return;
    }

    if (_selectedDate != null) {
      if (tenthYear <= _selectedDate!.year ||
          twelfthYear <= _selectedDate!.year) {
        CustomToast.showError(
          context,
          'Passing year cannot be same as or before Date of Birth year',
        );
        return;
      }
    }

    // 5. Disability Percentage Validation (0-100)
    if (_isPhysicallyDisabled) {
      final percent = int.tryParse(_disabilityPercentController.text);
      if (percent == null || percent < 0 || percent > 100) {
        CustomToast.showError(
          context,
          'Disability percentage must be between 0 and 100',
        );
        return;
      }
    }

    // 6. Mandatory Documents Check
    if ((_remotePhotoUrl == null && _photoFile == null) ||
        (_remoteSignatureUrl == null && _signatureFile == null) ||
        (_remoteAadharUrl == null && _aadhaarFile == null)) {
      CustomToast.showError(
        context,
        'Photo, Signature, and Aadhaar Card document are mandatory',
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
        'maritalStatus': _selectedMaritalStatus?.toUpperCase(),
        'idProofType': _idProofMapping[_selectedIdProofType],
        'idProofNumber': _idProofNumberController.text,
        'aadhaarNumber': _aadhaarController.text,
        'isPhysicallyDisabled': _isPhysicallyDisabled,
        'nationality': _selectedNationality?.toUpperCase(),
        'category': _selectedCategory,

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

        // Include existing address data to satisfy backend validation
        'presentAddress': _savedPresentAddress ?? '',
        'permanentAddress': _savedPermanentAddress ?? '',
        'correspondenceAddress': _savedCorrespondenceAddress ?? '',
        'state': _savedState ?? '',
        'district': _savedDistrict ?? '',
        'taluka': _savedTaluka ?? '',
        'pinCode': _savedPinCode ?? '',
      };

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddressPage(),
            settings: RouteSettings(
              arguments: {
                'isEditing': _isEditingFromProfile,
                'bioData': profileData,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage(bool isPhoto) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload ${isPhoto ? 'Photo' : 'Signature'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: OtrTheme.darkNavy,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: OtrTheme.primaryBlue,
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: OtrTheme.primaryBlue,
              ),
              title: const Text(
                'Capture from Camera',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image != null) {
      final file = File(image.path);
      final int sizeInBytes = await file.length();
      if (sizeInBytes > 500 * 1024) {
        if (mounted) {
          CustomToast.showError(context, 'File size exceeds 500 KB limit');
        }
        return;
      }
      setState(() {
        if (isPhoto) {
          _photoFile = file;
        } else {
          _signatureFile = file;
        }
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
            if (result['data'] != null) {
              setState(() {
                if (isPhoto && result['data']['photoUrl'] != null) {
                  String url = result['data']['photoUrl'];
                  if (url.startsWith('http')) {
                    _remotePhotoUrl = url;
                  } else {
                    final String base = ApiConstants.baseUrl.endsWith('/')
                        ? ApiConstants.baseUrl.substring(
                            0,
                            ApiConstants.baseUrl.length - 1,
                          )
                        : ApiConstants.baseUrl;
                    final String path = url.startsWith('/') ? url : '/$url';
                    _remotePhotoUrl = '$base$path';
                  }
                } else if (!isPhoto && result['data']['signatureUrl'] != null) {
                  String url = result['data']['signatureUrl'];
                  if (url.startsWith('http')) {
                    _remoteSignatureUrl = url;
                  } else {
                    final String base = ApiConstants.baseUrl.endsWith('/')
                        ? ApiConstants.baseUrl.substring(
                            0,
                            ApiConstants.baseUrl.length - 1,
                          )
                        : ApiConstants.baseUrl;
                    final String path = url.startsWith('/') ? url : '/$url';
                    _remoteSignatureUrl = '$base$path';
                  }
                }
              });
            }

            CustomToast.showSuccess(
              context,
              '${isPhoto ? 'Photo' : 'Signature'} uploaded successfully',
            );
          } else {
            CustomToast.showSuccess(
              context,
              result['message'] ?? 'Upload failed',
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

  Future<void> _pickAadhaar() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Upload Aadhaar Card',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: OtrTheme.darkNavy,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: OtrTheme.primaryBlue,
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: OtrTheme.primaryBlue,
              ),
              title: const Text(
                'Capture from Camera',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image != null) {
      final file = File(image.path);
      final int sizeInBytes = await file.length();
      if (sizeInBytes > 500 * 1024) {
        if (mounted) {
          CustomToast.showError(context, 'File size exceeds 500 KB limit');
        }
        return;
      }
      setState(() {
        _aadhaarFile = file;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading Aadhaar card...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      try {
        final result = await _apiService.uploadDocument(file, 'AADHAR');

        if (mounted) {
          if (result['success'] == true) {
            CustomToast.showSuccess(
              context,
              'Aadhaar card uploaded successfully',
            );
            _fetchAadhaarDocument();
          } else {
            CustomToast.showError(
              context,
              result['message'] ?? 'Upload failed',
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
                      _buildFunctionalDropdown(
                        label: 'Title',
                        hint: 'Mr.',
                        icon: Icons.title_rounded,
                        value: _selectedTitle,
                        items: ['Mr.', 'Ms.', 'Mrs.', 'Dr.'],
                        onChanged: _isReadOnly
                            ? null
                            : (val) => setState(() => _selectedTitle = val),
                      ),
                      const SizedBox(height: 20),
                      OtrTextField(
                        label: 'Surname',
                        hintText: 'Surname',
                        icon: Icons.person_outline_rounded,
                        controller: _surnameController,
                        enabled: !_isReadOnly,
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),
                      OtrTextField(
                        label: 'First Name',
                        hintText: 'Enter first name',
                        icon: Icons.person_rounded,
                        controller: _firstNameController,
                        enabled: !_isReadOnly,
                        isRequired: true,
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
                        enabled: !_isReadOnly,
                      ),
                      const SizedBox(height: 20),
                      OtrTextField(
                        label: 'Mother\'s Name',
                        hintText: 'Mother\'s Name',
                        icon: Icons.person_add_rounded,
                        controller: _motherController,
                        enabled: !_isReadOnly,
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
                        isRequired: true,
                        items: [
                          'Aadhaar Card',
                          'PAN Card',
                          'Voter ID',
                          'Driving License',
                        ],
                        onChanged: _isReadOnly
                            ? null
                            : (val) {
                                setState(() {
                                  _selectedIdProofType = val;
                                  if (val == 'Aadhaar Card') {
                                    _idProofNumberController.text =
                                        _aadhaarController.text;
                                  }
                                });
                              },
                      ),
                      if (_selectedIdProofType != 'Aadhaar Card') ...[
                        const SizedBox(height: 20),
                        OtrTextField(
                          label: 'ID Proof Number',
                          hintText: 'Enter ID number',
                          icon: Icons.tag_rounded,
                          controller: _idProofNumberController,
                          enabled: !_isReadOnly,
                          isRequired: true,
                        ),
                      ],
                      const SizedBox(height: 20),
                      OtrTextField(
                        label: 'Aadhaar Number',
                        hintText: '12-digit number',
                        icon: Icons.credit_card_rounded,
                        controller: _aadhaarController,
                        enabled: !_isReadOnly,
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(12),
                        ],
                      ),
                    ],
                  ),
                  _buildCollapsibleSection(
                    index: 2,
                    title: 'Personal Demographics',
                    icon: Icons.public_rounded,
                    children: [
                      _buildFunctionalDropdown(
                        label: 'Gender',
                        hint: 'Gender',
                        icon: Icons.transgender_rounded,
                        value: _selectedGender,
                        items: ['MALE', 'FEMALE', 'OTHER'],
                        isRequired: true,
                        onChanged: _isReadOnly
                            ? null
                            : (val) => setState(() => _selectedGender = val),
                      ),
                      const SizedBox(height: 20),
                      _buildClickableField(
                        label: 'Date of Birth',
                        value: _getFormattedDate(),
                        icon: Icons.calendar_today_rounded,
                        isRequired: true,
                        onTap: _isReadOnly ? null : () => _selectDate(context),
                      ),
                      const SizedBox(height: 20),
                      _buildFunctionalDropdown(
                        label: 'Marital Status',
                        hint: 'Select status',
                        icon: Icons.favorite_rounded,
                        value: _selectedMaritalStatus,
                        items: ['Single', 'Married', 'Divorced', 'Widow'],
                        onChanged: _isReadOnly
                            ? null
                            : (val) =>
                                  setState(() => _selectedMaritalStatus = val),
                      ),
                      const SizedBox(height: 20),
                      _buildFunctionalDropdown(
                        label: 'Nationality',
                        hint: 'Select nationality',
                        icon: Icons.flag_rounded,
                        value: _selectedNationality,
                        items: ['Indian', 'Other'],
                        onChanged: _isReadOnly
                            ? null
                            : (val) =>
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
                        label: 'Category',
                        hint: 'Select Category',
                        icon: Icons.category_rounded,
                        value: _selectedCategory,
                        items: ['UR', 'EWS', 'SC', 'ST', 'OBC'],
                        isRequired: true,
                        onChanged: _isReadOnly
                            ? null
                            : (val) => setState(() => _selectedCategory = val),
                      ),

                      const SizedBox(height: 20),
                      _buildFunctionalDropdown(
                        label: 'Highest Qualification',
                        hint: 'Select Highest',
                        icon: Icons.school_rounded,
                        value: _selectedQualification,
                        items: ['10th', '12th', 'Bachelor', 'Master', 'PhD'],
                        isRequired: true,
                        onChanged: _isReadOnly
                            ? null
                            : (val) =>
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
                              enabled: !_isReadOnly,
                              isRequired: true,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]'),
                                ),
                              ],
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
                              enabled: !_isReadOnly,
                              isRequired: true,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
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
                              enabled: !_isReadOnly,
                              isRequired: true,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]'),
                                ),
                              ],
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
                              enabled: !_isReadOnly,
                              isRequired: true,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const SizedBox(height: 24),
                      _buildSwitchTile(
                        'Physically Disabled',
                        _isPhysicallyDisabled,
                        _isReadOnly
                            ? null
                            : (val) =>
                                  setState(() => _isPhysicallyDisabled = val),
                      ),
                      if (_isPhysicallyDisabled) ...[
                        OtrTextField(
                          label: 'Disability Type',
                          hintText: 'Type',
                          icon: Icons.accessibility_new_rounded,
                          controller: _disabilityTypeController,
                          enabled: !_isReadOnly,
                        ),
                        const SizedBox(height: 12),
                        OtrTextField(
                          label: 'Percentage (%)',
                          hintText: '40',
                          icon: Icons.percent_rounded,
                          controller: _disabilityPercentController,
                          keyboardType: TextInputType.number,
                          enabled: !_isReadOnly,
                        ),
                      ],
                      _buildSwitchTile(
                        'Sports Person',
                        _isSportsPerson,
                        _isReadOnly
                            ? null
                            : (val) => setState(() => _isSportsPerson = val),
                      ),
                      if (_isSportsPerson) ...[
                        OtrTextField(
                          label: 'Sports Name',
                          hintText: 'Name',
                          icon: Icons.emoji_events_rounded,
                          controller: _sportsNameController,
                          enabled: !_isReadOnly,
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
                                enabled: !_isReadOnly,
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
                                enabled: !_isReadOnly,
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
                          enabled: !_isReadOnly,
                        ),
                      ],
                      _buildSwitchTile(
                        'Widow Person',
                        _isWidow,
                        _isReadOnly
                            ? null
                            : (val) => setState(() => _isWidow = val),
                      ),
                      if (_isWidow) ...[
                        OtrTextField(
                          label: 'Certificate No.',
                          hintText: 'Number',
                          icon: Icons.description_rounded,
                          controller: _widowCertController,
                          enabled: !_isReadOnly,
                        ),
                        const SizedBox(height: 12),
                        _buildClickableField(
                          label: 'Certificate Date',
                          value: _widowDateController.text.isEmpty
                              ? 'Select Date'
                              : _widowDateController.text,
                          icon: Icons.calendar_month_rounded,
                          onTap: _isReadOnly
                              ? null
                              : () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime.now(),
                                  );
                                  if (d != null) {
                                    setState(
                                      () => _widowDateController.text =
                                          DateFormat('yyyy-MM-dd').format(d),
                                    );
                                  }
                                },
                        ),
                      ],
                      _buildSwitchTile(
                        'Ex-Soldier',
                        _isExSoldier,
                        _isReadOnly
                            ? null
                            : (val) => setState(() => _isExSoldier = val),
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
                                enabled: !_isReadOnly,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OtrTextField(
                                label: 'Service To',
                                hintText: '2020',
                                icon: Icons.logout_rounded,
                                controller: _exSoldierToController,
                                enabled: !_isReadOnly,
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
                          enabled: !_isReadOnly,
                        ),
                      ],
                      _buildSwitchTile(
                        'Govt Employee',
                        _isGovtEmployee,
                        _isReadOnly
                            ? null
                            : (val) => setState(() => _isGovtEmployee = val),
                      ),
                      if (_isGovtEmployee) ...[
                        OtrTextField(
                          label: 'Dept Name',
                          hintText: 'Department',
                          icon: Icons.business_rounded,
                          controller: _govtDeptController,
                          enabled: !_isReadOnly,
                        ),
                        const SizedBox(height: 12),
                        _buildClickableField(
                          label: 'Join Date',
                          value: _govtJoinDateController.text.isEmpty
                              ? 'Select Date'
                              : _govtJoinDateController.text,
                          icon: Icons.calendar_month_rounded,
                          onTap: _isReadOnly
                              ? null
                              : () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime.now(),
                                  );
                                  if (d != null) {
                                    setState(
                                      () => _govtJoinDateController.text =
                                          DateFormat('yyyy-MM-dd').format(d),
                                    );
                                  }
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
                        _isReadOnly
                            ? null
                            : (r, w, s) => setState(() {
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
                        _isReadOnly
                            ? null
                            : (r, w, s) => setState(() {
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
                        _isReadOnly
                            ? null
                            : (r, w, s) => setState(() {
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
      onPressed: _isSaving
          ? null
          : () {
              if (_isReadOnly) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressPage(),
                    settings: RouteSettings(
                      arguments: {'isEditing': _isEditingFromProfile},
                    ),
                  ),
                );
              } else {
                _handleSave();
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: OtrTheme.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: OtrTheme.primaryBlue.withValues(alpha: 0.2),
      ),
      child: _isSaving
          ? const SpinKitThreeBounce(color: Colors.white, size: 20)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'PROCEED TO ADDRESS',
                  style: TextStyle(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18),
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
                ? OtrTheme.primaryBlue.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isExpanded
              ? OtrTheme.primaryBlue.withValues(alpha: 0.1)
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
    required VoidCallback? onTap,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: OtrTheme.darkNavy,
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
        const SizedBox(height: 10),
        InkWell(
          onTap: _isReadOnly ? null : onTap,
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
    required ValueChanged<String?>? onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: RichText(
            text: TextSpan(
              text: label,
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
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: OtrTheme.softShadow,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: items.contains(value) ? value : null,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
              size: 20,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: OtrTheme.primaryBlue, size: 22),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 4,
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
                fontWeight: FontWeight.w500,
              ),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: OtrTheme.darkNavy,
              fontWeight: FontWeight.w600,
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: _isReadOnly ? null : onChanged,
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
    Function(bool, bool, bool)? onChanged,
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
                onChanged == null
                    ? null
                    : (val) => onChanged(val, write, speak),
              ),
              _buildProficiencyChip(
                'Write',
                write,
                onChanged == null ? null : (val) => onChanged(read, val, speak),
              ),
              _buildProficiencyChip(
                'Speak',
                speak,
                onChanged == null ? null : (val) => onChanged(read, write, val),
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
    ValueChanged<bool>? onTap,
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
      selectedColor: OtrTheme.primaryBlue.withValues(alpha: 0.1),
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
    ValueChanged<bool>? onChanged,
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
        activeThumbColor: OtrTheme.primaryBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
      ),
    );
  }

  Widget _buildMediaUploadSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMediaCard(
                'Photo',
                _photoFile,
                _remotePhotoUrl,
                Icons.camera_alt_rounded,
                () => _pickImage(true),
                () => _handleDeleteMedia(true),
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
                () => _handleDeleteMedia(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMediaCard(
          'Aadhaar Card',
          _aadhaarFile,
          _remoteAadharUrl,
          Icons.credit_card_rounded,
          () => _pickAadhaar(),
          () => _handleDeleteAadhaar(),
        ),
      ],
    );
  }

  Future<void> _handleDeleteMedia(bool isPhoto) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${isPhoto ? 'Photo' : 'Signature'}?'),
        content: const Text(
          'Are you sure you want to permanently remove this image?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
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
            CustomToast.showSuccess(
              context,
              '${isPhoto ? 'Photo' : 'Signature'} deleted successfully',
            );
          } else {
            CustomToast.showError(
              context,
              result['message'] ?? 'Delete failed',
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
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeleteAadhaar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Aadhaar Card?'),
        content: const Text(
          'Are you sure you want to permanently remove this document?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final result = await _apiService.deleteDocument('AADHAR');

        if (mounted) {
          if (result['success'] == true) {
            setState(() {
              _aadhaarFile = null;
              _remoteAadharUrl = null;
            });
            CustomToast.showSuccess(
              context,
              'Aadhaar card deleted successfully',
            );
          } else {
            CustomToast.showError(
              context,
              result['message'] ?? 'Delete failed',
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
                color: OtrTheme.primaryBlue.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red.shade700,
                  size: 18,
                ),
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
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: OtrTheme.darkNavy,
                fontSize: 13,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
          Text(
            isError ? 'Reload Required' : 'Max Size: 500 KB',
            style: TextStyle(
              color: isError ? Colors.red : Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
