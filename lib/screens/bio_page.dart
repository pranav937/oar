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

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherController = TextEditingController();
  final TextEditingController _motherController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _idProofNumberController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _tenthBoardController = TextEditingController();
  final TextEditingController _tenthYearController = TextEditingController();
  final TextEditingController _twelfthBoardController = TextEditingController();
  final TextEditingController _twelfthYearController = TextEditingController();

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
      _nameController.text = '${_firstNameController.text} ${_surnameController.text}'.trim();
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
          _titleController.text = data['title'] ?? '';
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
          _tenthYearController.text = data['tenthPassingYear']?.toString() ?? '';
          _twelfthBoardController.text = data['twelfthBoardName'] ?? '';
          _twelfthYearController.text = data['twelfthPassingYear']?.toString() ?? '';

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
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final profileData = {
        'title': _titleController.text,
        'firstName': _firstNameController.text,
        'surname': _surnameController.text,
        'fullName': '${_firstNameController.text} ${_surnameController.text}'.trim(),
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
        'englishProficiency': {'read': _engRead, 'write': _engWrite, 'speak': _engSpeak},
        'hindiProficiency': {'read': _hinRead, 'write': _hinWrite, 'speak': _hinSpeak},
        'gujaratiProficiency': {'read': _gujRead, 'write': _gujWrite, 'speak': _gujSpeak},
        'highestQualification': _selectedQualification,
        'tenthBoardName': _tenthBoardController.text,
        'tenthPassingYear': int.tryParse(_tenthYearController.text),
        'twelfthBoardName': _twelfthBoardController.text,
        'twelfthPassingYear': int.tryParse(_twelfthYearController.text),
      };

      final result = await _apiService.updateProfile(profileData);
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressPage()));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Update failed')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
      body: _isLoading
          ? const Center(child: SpinKitRing(color: OtrTheme.primaryBlue))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressTracker(),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Candidate Profile', 'Complete your personal and social details'),
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
                                  child: OtrTextField(label: 'Title', hintText: 'Mr.', icon: Icons.title_rounded, controller: _titleController),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: OtrTextField(label: 'Surname', hintText: 'Surname', icon: Icons.person_outline_rounded, controller: _surnameController),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            OtrTextField(label: 'First Name', hintText: 'Enter first name', icon: Icons.person_rounded, controller: _firstNameController),
                            const SizedBox(height: 20),
                            OtrTextField(label: 'Full Name', hintText: 'Auto-generated', icon: Icons.badge_rounded, controller: _nameController, enabled: false),
                            const SizedBox(height: 20),
                            OtrTextField(label: 'Father\'s Name', hintText: 'Father\'s Name', icon: Icons.person_add_rounded, controller: _fatherController),
                            const SizedBox(height: 20),
                            OtrTextField(label: 'Mother\'s Name', hintText: 'Mother\'s Name', icon: Icons.person_add_rounded, controller: _motherController),
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
                              items: ['Aadhaar Card', 'PAN Card', 'Voter ID', 'Driving License'],
                              onChanged: (val) => setState(() => _selectedIdProofType = val),
                            ),
                            const SizedBox(height: 20),
                            OtrTextField(label: 'ID Proof Number', hintText: 'Enter ID number', icon: Icons.tag_rounded, controller: _idProofNumberController),
                            const SizedBox(height: 20),
                            OtrTextField(label: 'Aadhaar Number', hintText: '12-digit number', icon: Icons.credit_card_rounded, controller: _aadhaarController),
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
                                    onChanged: (val) => setState(() => _selectedGender = val),
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
                              onChanged: (val) => setState(() => _selectedMaritalStatus = val),
                            ),
                            const SizedBox(height: 20),
                            _buildFunctionalDropdown(
                              label: 'Nationality',
                              hint: 'Select nationality',
                              icon: Icons.flag_rounded,
                              value: _selectedNationality,
                              items: ['Indian', 'Other'],
                              onChanged: (val) => setState(() => _selectedNationality = val),
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
                              items: ['10th', '12th', 'B.Tech', 'B.Sc', 'M.Tech', 'PhD'],
                              onChanged: (val) => setState(() => _selectedQualification = val),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OtrTextField(label: '10th Board', hintText: 'Education Board', icon: Icons.history_edu_rounded, controller: _tenthBoardController),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OtrTextField(label: 'Year', hintText: '2010', icon: Icons.calendar_today, controller: _tenthYearController, keyboardType: TextInputType.number),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OtrTextField(label: '12th Board', hintText: 'Education Board', icon: Icons.history_edu_rounded, controller: _twelfthBoardController),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OtrTextField(label: 'Year', hintText: '2012', icon: Icons.calendar_today, controller: _twelfthYearController, keyboardType: TextInputType.number),
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
                                    onChanged: (val) => setState(() => _selectedCommunity = val),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OtrTextField(label: 'Sub Category', hintText: 'Sub-category', icon: Icons.category_rounded, controller: _subCategoryController),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSwitchTile('Physically Disabled', _isPhysicallyDisabled, (val) => setState(() => _isPhysicallyDisabled = val)),
                            _buildSwitchTile('Sports Person', _isSportsPerson, (val) => setState(() => _isSportsPerson = val)),
                            _buildSwitchTile('Widow Person', _isWidow, (val) => setState(() => _isWidow = val)),
                            _buildSwitchTile('Ex-Soldier', _isExSoldier, (val) => setState(() => _isExSoldier = val)),
                            _buildSwitchTile('Govt Employee', _isGovtEmployee, (val) => setState(() => _isGovtEmployee = val)),
                          ],
                        ),
                        _buildCollapsibleSection(
                          index: 4,
                          title: 'Language Proficiency',
                          icon: Icons.translate_rounded,
                          children: [
                            _buildLanguageCard('English', _engRead, _engWrite, _engSpeak, (r, w, s) => setState(() { _engRead = r; _engWrite = w; _engSpeak = s; })),
                            const SizedBox(height: 12),
                            _buildLanguageCard('Hindi', _hinRead, _hinWrite, _hinSpeak, (r, w, s) => setState(() { _hinRead = r; _hinWrite = w; _hinSpeak = s; })),
                            const SizedBox(height: 12),
                            _buildLanguageCard('Gujarati', _gujRead, _gujWrite, _gujSpeak, (r, w, s) => setState(() { _gujRead = r; _gujWrite = w; _gujSpeak = s; })),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildSaveButton(),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: OtrTheme.darkNavy,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: const Text('Personal Bio', style: TextStyle(color: OtrTheme.darkNavy, fontWeight: FontWeight.w900, fontSize: 18)),
        background: Container(color: Colors.white),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
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
            color: isActive ? OtrTheme.primaryBlue : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: isActive ? [BoxShadow(color: OtrTheme.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          child: Center(child: Text(step, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? OtrTheme.primaryBlue : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
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
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
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
                Text('SAVE & PROCEED', style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.w900)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
    );
  }

  Widget _buildCollapsibleSection({required int index, required String title, required IconData icon, required List<Widget> children}) {
    bool isExpanded = _expandedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isExpanded ? OtrTheme.primaryBlue.withOpacity(0.08) : Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: isExpanded ? OtrTheme.primaryBlue.withOpacity(0.3) : Colors.transparent, width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: index == 0,
          onExpansionChanged: (expanded) => setState(() => _expandedIndex = expanded ? index : -1),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isExpanded ? OtrTheme.primaryBlue : OtrTheme.lightBlue, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: isExpanded ? Colors.white : OtrTheme.primaryBlue, size: 20),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: isExpanded ? OtrTheme.primaryBlue : OtrTheme.darkNavy, fontSize: 15)),
          trailing: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isExpanded ? OtrTheme.primaryBlue : Colors.grey),
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

  Widget _buildClickableField({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: IgnorePointer(
            child: OtrTextField(label: '', hintText: value, icon: icon),
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionalDropdown({required String label, required String hint, required IconData icon, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: OtrTheme.primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            filled: true,
            fillColor: OtrTheme.background,
          ),
          hint: Text(hint),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLanguageCard(String language, bool read, bool write, bool speak, Function(bool, bool, bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: OtrTheme.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language, style: const TextStyle(fontWeight: FontWeight.bold, color: OtrTheme.darkNavy, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProficiencyChip('Read', read, (val) => onChanged(val, write, speak)),
              _buildProficiencyChip('Write', write, (val) => onChanged(read, val, speak)),
              _buildProficiencyChip('Speak', speak, (val) => onChanged(read, write, val)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProficiencyChip(String label, bool isSelected, ValueChanged<bool> onTap) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: onTap,
      selectedColor: OtrTheme.primaryBlue.withOpacity(0.1),
      checkmarkColor: OtrTheme.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: isSelected ? OtrTheme.primaryBlue : Colors.grey.shade300),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: OtrTheme.background, borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: OtrTheme.darkNavy)),
        value: value,
        onChanged: onChanged,
        activeColor: OtrTheme.primaryBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
      ),
    );
  }
}
