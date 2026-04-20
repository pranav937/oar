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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherController = TextEditingController();
  final TextEditingController _motherController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();

  String? _selectedGender;
  String? _selectedCommunity;
  String? _selectedNationality;
  String? _selectedQualification;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await _apiService.getProfile();
      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          _nameController.text = data['fullName'] ?? '';
          _fatherController.text = data['fatherName'] ?? '';
          _motherController.text = data['motherName'] ?? '';
          _mobileController.text = data['mobileNumber'] ?? '';
          _emailController.text = data['email'] ?? '';
          _aadhaarController.text = data['aadhaarNumber'] ?? '';
          
          _selectedGender = data['gender'];
          _selectedCommunity = data['category']; 
          _selectedNationality = data['nationality'] ?? 'Indian';
          _selectedQualification = data['highestQualification'];
          
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
        'fullName': _nameController.text,
        'fatherName': _fatherController.text,
        'motherName': _motherController.text,
        'gender': _selectedGender,
        'dateOfBirth': _selectedDate?.toIso8601String(),
        'category': _selectedCommunity,
        'nationality': _selectedNationality,
        'highestQualification': _selectedQualification,
        'aadhaarNumber': _aadhaarController.text,
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
      appBar: AppBar(
        title: const Text('Personal Bio', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.white,
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildCollapsibleSection(
                    index: 0,
                    title: 'Basic Info',
                    icon: Icons.badge_outlined,
                    children: [
                      OtrTextField(label: 'Full Name', hintText: 'Enter name', icon: Icons.person, controller: _nameController),
                      const SizedBox(height: 24),
                      OtrTextField(label: 'Father\'s Name', hintText: 'Enter father\'s name', icon: Icons.person_add, controller: _fatherController),
                      const SizedBox(height: 24),
                      OtrTextField(label: 'Mother\'s Name', hintText: 'Enter mother\'s name', icon: Icons.person_add, controller: _motherController),
                    ],
                  ),
                  _buildCollapsibleSection(
                    index: 1,
                    title: 'Contact Details',
                    icon: Icons.contact_mail_outlined,
                    children: [
                      OtrTextField(label: 'Mobile Number', hintText: '10 digit mobile', icon: Icons.phone, controller: _mobileController, enabled: false),
                      const SizedBox(height: 24),
                      OtrTextField(label: 'Email Address', hintText: 'Enter email', icon: Icons.email, controller: _emailController, enabled: false),
                    ],
                  ),
                  _buildCollapsibleSection(
                    index: 2,
                    title: 'Demographics',
                    icon: Icons.assignment_ind_outlined,
                    children: [
                      _buildFunctionalDropdown(
                        label: 'Gender',
                        hint: 'Select Gender',
                        icon: Icons.transgender,
                        value: _selectedGender,
                        items: ['MALE', 'FEMALE', 'OTHER'],
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                      const SizedBox(height: 24),
                      _buildClickableField(
                        label: 'Date of Birth',
                        value: _getFormattedDate(),
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 24),
                      _buildFunctionalDropdown(
                        label: 'Category',
                        hint: 'Select Category',
                        icon: Icons.groups,
                        value: _selectedCommunity,
                        items: ['UR', 'SC', 'ST', 'OBC', 'EWS'],
                        onChanged: (val) => setState(() => _selectedCommunity = val),
                      ),
                    ],
                  ),
                  _buildCollapsibleSection(
                    index: 3,
                    title: 'Identity',
                    icon: Icons.fingerprint,
                    children: [
                      OtrTextField(label: 'Aadhaar Number', hintText: '12 digit number', icon: Icons.credit_card, controller: _aadhaarController),
                      const SizedBox(height: 24),
                      _buildFunctionalDropdown(
                        label: 'Highest Qualification',
                        hint: 'Select Highest',
                        icon: Icons.school,
                        value: _selectedQualification,
                        items: ['10th', '12th', 'B.Tech', 'B.Sc', 'M.Tech', 'PhD'],
                        onChanged: (val) => setState(() => _selectedQualification = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OtrTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SAVE & CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildCollapsibleSection({required int index, required String title, required IconData icon, required List<Widget> children}) {
    bool isExpanded = _expandedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expandedIndex = isExpanded ? -1 : index),
            leading: Icon(icon, color: OtrTheme.primaryBlue),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: OtrTheme.darkNavy)),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          ),
          if (isExpanded) Padding(padding: const EdgeInsets.all(20), child: Column(children: children)),
        ],
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
}
