import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../widgets/otr_text_field.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/custom_toast.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final ApiService _apiService = ApiService();
  int _expandedIndex = 0;
  bool _isPermanentSameAsCurrent = false;
  bool _isCorrespondenceSameAsCurrent = false;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _pFlatController = TextEditingController();
  final TextEditingController _pTalukaController = TextEditingController();
  final TextEditingController _pDistrictController = TextEditingController();
  final TextEditingController _pStateController = TextEditingController();
  final TextEditingController _pPincodeController = TextEditingController();

  final TextEditingController _cFlatController = TextEditingController();
  final TextEditingController _cTalukaController = TextEditingController();
  final TextEditingController _cDistrictController = TextEditingController();
  final TextEditingController _cStateController = TextEditingController();
  final TextEditingController _cPincodeController = TextEditingController();

  final TextEditingController _currFlatController = TextEditingController();
  final TextEditingController _currTalukaController = TextEditingController();
  final TextEditingController _currDistrictController = TextEditingController();
  final TextEditingController _currStateController = TextEditingController();
  final TextEditingController _currPincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAddress();

    // Add listeners for real-time sync
    _currFlatController.addListener(_syncAddresses);
    _currTalukaController.addListener(_syncAddresses);
    _currDistrictController.addListener(_syncAddresses);
    _currStateController.addListener(_syncAddresses);
    _currPincodeController.addListener(_syncAddresses);
  }

  @override
  void dispose() {
    _currFlatController.dispose();
    _currTalukaController.dispose();
    _currDistrictController.dispose();
    _currStateController.dispose();
    _currPincodeController.dispose();

    _pFlatController.dispose();
    _pTalukaController.dispose();
    _pDistrictController.dispose();
    _pStateController.dispose();
    _pPincodeController.dispose();

    _cFlatController.dispose();
    _cTalukaController.dispose();
    _cDistrictController.dispose();
    _cStateController.dispose();
    _cPincodeController.dispose();
    super.dispose();
  }

  void _syncAddresses() {
    if (_isPermanentSameAsCurrent) {
      _pFlatController.text = _currFlatController.text;
      _pTalukaController.text = _currTalukaController.text;
      _pDistrictController.text = _currDistrictController.text;
      _pStateController.text = _currStateController.text;
      _pPincodeController.text = _currPincodeController.text;
    }
    if (_isCorrespondenceSameAsCurrent) {
      _cFlatController.text = _currFlatController.text;
      _cTalukaController.text = _currTalukaController.text;
      _cDistrictController.text = _currDistrictController.text;
      _cStateController.text = _currStateController.text;
      _cPincodeController.text = _currPincodeController.text;
    }
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
          _pTalukaController.text = data['taluka'] ?? '';
          _pPincodeController.text = data['pinCode'] ?? '';

          // Correspondence Address
          _cFlatController.text = data['correspondenceAddress'] ?? '';
          _cStateController.text = data['state'] ?? '';
          _cDistrictController.text = data['district'] ?? '';
          _cTalukaController.text = data['taluka'] ?? '';
          _cPincodeController.text = data['pinCode'] ?? '';

          // Current/Present Address
          _currFlatController.text = data['presentAddress'] ?? '';
          _currTalukaController.text = data['taluka'] ?? '';
          _currDistrictController.text = data['district'] ?? '';
          _currStateController.text = data['state'] ?? '';
          _currPincodeController.text = data['pinCode'] ?? '';

          if (_currFlatController.text.isNotEmpty) {
            if (_currFlatController.text == _pFlatController.text) {
              _isPermanentSameAsCurrent = true;
            }
            if (_currFlatController.text == _cFlatController.text) {
              _isCorrespondenceSameAsCurrent = true;
            }
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
        'correspondenceAddress': _cFlatController.text,
        'presentAddress': _currFlatController.text,
        'state': _currStateController.text, // Using current as primary
        'district': _currDistrictController.text,
        'taluka': _currTalukaController.text,
        'pinCode': _currPincodeController.text,
      };

      final result = await _apiService.updateProfile(profileData);
      if (result['success'] == true) {
        if (mounted) {
          CustomToast.showSuccess(context, 'Address updated successfully');
          Navigator.pushNamed(context, '/documents');
        }
      } else {
        if (mounted) {
          CustomToast.showSuccess(context, result['message'] ?? 'Update failed');
        }
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

  void _handlePermanentSync(bool? value) {
    setState(() {
      _isPermanentSameAsCurrent = value ?? false;
      if (_isPermanentSameAsCurrent) {
        _pFlatController.text = _currFlatController.text;
        _pTalukaController.text = _currTalukaController.text;
        _pDistrictController.text = _currDistrictController.text;
        _pStateController.text = _currStateController.text;
        _pPincodeController.text = _currPincodeController.text;
      }
    });
  }

  void _handleCorrespondenceSync(bool? value) {
    setState(() {
      _isCorrespondenceSameAsCurrent = value ?? false;
      if (_isCorrespondenceSameAsCurrent) {
        _cFlatController.text = _currFlatController.text;
        _cTalukaController.text = _currTalukaController.text;
        _cDistrictController.text = _currDistrictController.text;
        _cStateController.text = _currStateController.text;
        _cPincodeController.text = _currPincodeController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Address Info',
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
                    'Residence Details',
                    'Update your permanent and current addresses',
                  ),
                  const SizedBox(height: 24),
                  _buildCollapsibleSection(
                    index: 0,
                    title: 'Current Address',
                    icon: Icons.location_history_rounded,
                    children: [
                      OtrTextField(
                        label: 'Full Address',
                        hintText: 'Enter current address',
                        icon: Icons.map_rounded,
                        controller: _currFlatController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OtrTextField(
                              label: 'Taluka/City',
                              hintText: 'Taluka',
                              icon: Icons.location_on_rounded,
                              controller: _currTalukaController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OtrTextField(
                              label: 'District',
                              hintText: 'District',
                              icon: Icons.location_city_rounded,
                              controller: _currDistrictController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OtrTextField(
                              label: 'State',
                              hintText: 'State',
                              icon: Icons.flag_rounded,
                              controller: _currStateController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OtrTextField(
                              label: 'Pincode',
                              hintText: '6 digits',
                              icon: Icons.pin_drop_rounded,
                              controller: _currPincodeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isPermanentSameAsCurrent
                            ? OtrTheme.primaryBlue.withAlpha(76)
                            : Colors.transparent,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: _isPermanentSameAsCurrent,
                      onChanged: _handlePermanentSync,
                      title: const Text(
                        'Permanent Address Same as Current',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: OtrTheme.darkNavy,
                        ),
                      ),
                      activeColor: OtrTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isPermanentSameAsCurrent)
                    _buildCollapsibleSection(
                      index: 1,
                      title: 'Permanent Address',
                      icon: Icons.home_work_rounded,
                      children: [
                        OtrTextField(
                          label: 'Full Address',
                          hintText: 'Enter permanent address',
                          icon: Icons.map_rounded,
                          controller: _pFlatController,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OtrTextField(
                                label: 'Taluka/City',
                                hintText: 'Taluka',
                                icon: Icons.location_on_rounded,
                                controller: _pTalukaController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OtrTextField(
                                label: 'District',
                                hintText: 'District',
                                icon: Icons.location_city_rounded,
                                controller: _pDistrictController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OtrTextField(
                                label: 'State',
                                hintText: 'State',
                                icon: Icons.flag_rounded,
                                controller: _pStateController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OtrTextField(
                                label: 'Pincode',
                                hintText: '6 digits',
                                icon: Icons.pin_drop_rounded,
                                controller: _pPincodeController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isCorrespondenceSameAsCurrent
                            ? OtrTheme.primaryBlue.withAlpha(76)
                            : Colors.transparent,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: _isCorrespondenceSameAsCurrent,
                      onChanged: _handleCorrespondenceSync,
                      title: const Text(
                        'Correspondence Address Same as Current',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: OtrTheme.darkNavy,
                        ),
                      ),
                      activeColor: OtrTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isCorrespondenceSameAsCurrent)
                    _buildCollapsibleSection(
                      index: 2,
                      title: 'Correspondence Address',
                      icon: Icons.mail_rounded,
                      children: [
                        OtrTextField(
                          label: 'Full Address',
                          hintText: 'Enter correspondence address',
                          icon: Icons.map_rounded,
                          controller: _cFlatController,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OtrTextField(
                                label: 'Taluka/City',
                                hintText: 'Taluka',
                                icon: Icons.location_on_rounded,
                                controller: _cTalukaController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OtrTextField(
                                label: 'District',
                                hintText: 'District',
                                icon: Icons.location_city_rounded,
                                controller: _cDistrictController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OtrTextField(
                                label: 'State',
                                hintText: 'State',
                                icon: Icons.flag_rounded,
                                controller: _cStateController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OtrTextField(
                                label: 'Pincode',
                                hintText: '6 digits',
                                icon: Icons.pin_drop_rounded,
                                controller: _cPincodeController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 48),
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
        _buildStepIndicator('1', 'Bio', true, true),
        _buildStepLine(true),
        _buildStepIndicator('2', 'Address', true, false),
        _buildStepLine(false),
        _buildStepIndicator('3', 'Docs', false, false),
      ],
    );
  }

  Widget _buildStepIndicator(
    String step,
    String label,
    bool isActive,
    bool isDone,
  ) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? OtrTheme.primaryBlue
                : Colors.grey.withAlpha(51),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: OtrTheme.primaryBlue.withAlpha(76),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
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
        color: isDone ? OtrTheme.primaryBlue : Colors.grey.withAlpha(51),
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
        shadowColor: OtrTheme.primaryBlue.withAlpha(102),
      ),
      child: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
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
                ? OtrTheme.primaryBlue.withAlpha(20)
                : Colors.black.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isExpanded
              ? OtrTheme.primaryBlue.withAlpha(76)
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
}
