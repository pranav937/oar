import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../widgets/otr_text_field.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final ApiService _apiService = ApiService();
  int _expandedIndex = 0;
  bool _isSameAsPermanent = false;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _pFlatController = TextEditingController();
  final TextEditingController _pStreetController = TextEditingController();
  final TextEditingController _pLandmarkController = TextEditingController();
  final TextEditingController _pDistrictController = TextEditingController();
  final TextEditingController _pStateController = TextEditingController();
  final TextEditingController _pPincodeController = TextEditingController();

  final TextEditingController _cFlatController = TextEditingController();
  final TextEditingController _cStreetController = TextEditingController();
  final TextEditingController _cLandmarkController = TextEditingController();
  final TextEditingController _cDistrictController = TextEditingController();
  final TextEditingController _cStateController = TextEditingController();
  final TextEditingController _cPincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    try {
      final result = await _apiService.getProfile();
      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          // Permanent Address
          _pFlatController.text = data['permanentAddress'] ?? '';
          _pStateController.text = data['state'] ?? '';
          _pDistrictController.text = data['district'] ?? '';
          _pPincodeController.text = data['pinCode'] ?? '';

          // Correspondence Address (Current)
          _cFlatController.text = data['correspondenceAddress'] ?? '';

          if (_pFlatController.text == _cFlatController.text &&
              _pFlatController.text.isNotEmpty) {
            _isSameAsPermanent = true;
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
        'permanentAddress': _pFlatController.text,
        'correspondenceAddress': _isSameAsPermanent
            ? _pFlatController.text
            : _cFlatController.text,
        'state': _pStateController.text,
        'district': _pDistrictController.text,
        'pinCode': _pPincodeController.text,
      };

      final result = await _apiService.updateProfile(profileData);
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully')),
          );
          Navigator.pushNamed(context, '/documents');
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

  void _handleCheckbox(bool? value) {
    setState(() {
      _isSameAsPermanent = value ?? false;
      if (_isSameAsPermanent) {
        _cFlatController.text = _pFlatController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Address Details',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: SpinKitRing(color: OtrTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildCollapsibleSection(
                    index: 0,
                    title: 'Permanent Address',
                    icon: Icons.home_work_outlined,
                    children: [
                      OtrTextField(
                        label: 'Full Address',
                        hintText: 'Enter permanent address',
                        icon: Icons.map,
                        controller: _pFlatController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      OtrTextField(
                        label: 'District',
                        hintText: 'Enter district',
                        icon: Icons.location_city,
                        controller: _pDistrictController,
                      ),
                      const SizedBox(height: 24),
                      OtrTextField(
                        label: 'State',
                        hintText: 'Enter state',
                        icon: Icons.flag,
                        controller: _pStateController,
                      ),
                      const SizedBox(height: 24),
                      OtrTextField(
                        label: 'Pincode',
                        hintText: '6 digit pincode',
                        icon: Icons.pin_drop,
                        controller: _pPincodeController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _isSameAsPermanent,
                    onChanged: _handleCheckbox,
                    title: const Text(
                      'Same as Permanent Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    activeColor: OtrTheme.primaryBlue,
                  ),
                  const SizedBox(height: 8),
                  if (!_isSameAsPermanent)
                    _buildCollapsibleSection(
                      index: 1,
                      title: 'Correspondence Address',
                      icon: Icons.mail_outline,
                      children: [
                        OtrTextField(
                          label: 'Full Address',
                          hintText: 'Enter correspondence address',
                          icon: Icons.map,
                          controller: _cFlatController,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('SAVE & CONTINUE'),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.softShadow,
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () =>
                setState(() => _expandedIndex = isExpanded ? -1 : index),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: OtrTheme.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: OtrTheme.primaryBlue, size: 20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: OtrTheme.darkNavy,
                fontSize: 15,
              ),
            ),
            trailing: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }
}
