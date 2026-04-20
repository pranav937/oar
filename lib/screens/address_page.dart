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
  final TextEditingController _pTalukaController = TextEditingController();
  final TextEditingController _pDistrictController = TextEditingController();
  final TextEditingController _pStateController = TextEditingController();
  final TextEditingController _pPincodeController = TextEditingController();

  final TextEditingController _cFlatController = TextEditingController();
  final TextEditingController _cStreetController = TextEditingController();
  final TextEditingController _cLandmarkController = TextEditingController();
  final TextEditingController _cTalukaController = TextEditingController();
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
          _pTalukaController.text = data['taluka'] ?? '';
          _pPincodeController.text = data['pinCode'] ?? '';

          // Correspondence Address
          _cFlatController.text =
              data['correspondenceAddress'] ?? data['presentAddress'] ?? '';
          _cStateController.text = data['state'] ?? '';
          _cDistrictController.text = data['district'] ?? '';
          _cTalukaController.text = data['taluka'] ?? '';
          _cPincodeController.text = data['pinCode'] ?? '';

          if (_pFlatController.text.isNotEmpty &&
              _pFlatController.text == _cFlatController.text) {
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
        'presentAddress': _isSameAsPermanent
            ? _pFlatController.text
            : _cFlatController.text,
        'state': _pStateController.text,
        'district': _pDistrictController.text,
        'taluka': _pTalukaController.text,
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
                        _buildSectionHeader(
                          'Residence Details',
                          'Update your permanent and current addresses',
                        ),
                        const SizedBox(height: 24),
                        _buildCollapsibleSection(
                          index: 0,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isSameAsPermanent
                                  ? OtrTheme.primaryBlue.withOpacity(0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: _isSameAsPermanent,
                            onChanged: _handleCheckbox,
                            title: const Text(
                              'Same as Permanent Address',
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!_isSameAsPermanent)
                          _buildCollapsibleSection(
                            index: 1,
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
                            ],
                          ),
                        const SizedBox(height: 48),
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
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: OtrTheme.darkNavy,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: const Text(
          'Address Info',
          style: TextStyle(
            color: OtrTheme.darkNavy,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
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
}
