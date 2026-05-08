import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../widgets/otr_text_field.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/custom_toast.dart';
import 'package:flutter/services.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final ApiService _apiService = ApiService();
  int _expandedIndex = 0;
  bool _isPermanentSameAsCurrent = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isReadOnly = true;
  bool _isEditingFromProfile = false;

  Map<String, dynamic>? _bioData;

  // Saved profile data to preserve bio fields during address update
  Map<String, dynamic> _savedProfileData = {};

  // Master Data
  List<dynamic> _states = [];
  List<dynamic> _cities = [];
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;
  String? _selectedStateCode; // to keep track for city fetch
  String? _selectedPStateCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      if (args['isEditing'] == true) {
        _isEditingFromProfile = true;
      }
      if (args.containsKey('bioData')) {
        _bioData = args['bioData'] as Map<String, dynamic>?;
      }
    }
  }

  final TextEditingController _pFlatController = TextEditingController();
  final TextEditingController _pTalukaController = TextEditingController();
  final TextEditingController _pDistrictController = TextEditingController();
  final TextEditingController _pStateController = TextEditingController();
  final TextEditingController _pPincodeController = TextEditingController();

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

    _fetchStates();
  }

  Future<void> _fetchStates() async {
    setState(() => _isLoadingStates = true);
    final result = await _apiService.getStates();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _states = result['data'] ?? [];
        }
        _isLoadingStates = false;
      });
      // After fetching states, if there's an existing state in the controller,
      // trigger city fetch for it
      if (_currStateController.text.isNotEmpty) {
        final state = _states.firstWhere(
          (s) => s['name'] == _currStateController.text,
          orElse: () => null,
        );
        if (state != null) {
          _selectedStateCode = state['isoCode'];
          _fetchCities(_selectedStateCode!);
        }
      }
      if (_pStateController.text.isNotEmpty && !_isPermanentSameAsCurrent) {
        final pState = _states.firstWhere(
          (s) => s['name'] == _pStateController.text,
          orElse: () => null,
        );
        if (pState != null) {
          _selectedPStateCode = pState['isoCode'];
          _fetchCities(_selectedPStateCode!, isPermanent: true);
        }
      }
    }
  }

  Future<void> _fetchCities(
    String stateCode, {
    bool isPermanent = false,
  }) async {
    if (isPermanent) {
      setState(() => _isLoadingCities = true);
    } else {
      setState(() => _isLoadingCities = true);
    }

    final result = await _apiService.getCities(stateCode);
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _cities = result['data'] ?? [];
        }
        _isLoadingCities = false;
      });
    }
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
  }

  Future<void> _fetchAddress() async {
    try {
      final result = await _apiService.getProfile();
      if (result['success'] == true) {
        final data = result['data'];
        _savedProfileData = Map<String, dynamic>.from(data);
        setState(() {
          // Permanent Address
          _pFlatController.text = data['permanentAddress'] ?? '';
          _pStateController.text = data['state'] ?? '';
          _pDistrictController.text = data['district'] ?? '';
          _pTalukaController.text = data['taluka'] ?? '';
          _pPincodeController.text = data['pinCode'] ?? '';

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
          }

          if (_currFlatController.text.isNotEmpty && !_isEditingFromProfile) {
            _isReadOnly = true;
          } else {
            _isReadOnly = false;
          }

          // Trigger city fetch if state exists
          if (_currStateController.text.isNotEmpty && _states.isNotEmpty) {
            final state = _states.firstWhere(
              (s) => s['name'] == _currStateController.text,
              orElse: () => null,
            );
            if (state != null) {
              _selectedStateCode = state['isoCode'];
              _fetchCities(_selectedStateCode!);
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
    // Mandatory Fields Validation
    if (_currFlatController.text.trim().isEmpty) {
      CustomToast.showError(context, 'Current address is required');
      return;
    }
    if (_currTalukaController.text.trim().isEmpty) {
      CustomToast.showError(context, 'Taluka/City is required');
      return;
    }
    if (_currDistrictController.text.trim().isEmpty) {
      CustomToast.showError(context, 'District is required');
      return;
    }
    if (_currStateController.text.trim().isEmpty) {
      CustomToast.showError(context, 'State is required');
      return;
    }
    if (_currPincodeController.text.trim().isEmpty) {
      CustomToast.showError(context, 'Pincode is required');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(_currPincodeController.text.trim())) {
      CustomToast.showError(context, 'Pincode must be 6 digits');
      return;
    }

    if (!_isPermanentSameAsCurrent) {
      if (_pFlatController.text.trim().isEmpty) {
        CustomToast.showError(context, 'Permanent address is required');
        return;
      }
      if (_pTalukaController.text.trim().isEmpty) {
        CustomToast.showError(context, 'Permanent Taluka/City is required');
        return;
      }
      if (_pDistrictController.text.trim().isEmpty) {
        CustomToast.showError(context, 'Permanent District is required');
        return;
      }
      if (_pStateController.text.trim().isEmpty) {
        CustomToast.showError(context, 'Permanent State is required');
        return;
      }
      if (_pPincodeController.text.trim().isEmpty) {
        CustomToast.showError(context, 'Permanent Pincode is required');
        return;
      }
      if (!RegExp(r'^\d{6}$').hasMatch(_pPincodeController.text.trim())) {
        CustomToast.showError(context, 'Permanent Pincode must be 6 digits');
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final profileData = {
        ..._savedProfileData,
        if (_bioData != null) ..._bioData!,
        'permanentAddress': _pFlatController.text,
        'correspondenceAddress': _pFlatController.text,
        'presentAddress': _currFlatController.text,
        'state': _currStateController.text,
        'district': _currDistrictController.text,
        'taluka': _currTalukaController.text,
        'pinCode': _currPincodeController.text,
      };

      final result = await _apiService.updateProfile(profileData);
      if (result['success'] == true) {
        if (mounted) {
          CustomToast.showSuccess(context, 'Address updated successfully');
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          String errorMsg = result['message'] ?? 'Update failed';
          if (result['errors'] != null &&
              result['errors'] is List &&
              (result['errors'] as List).isNotEmpty) {
            final firstError = (result['errors'] as List).first;
            errorMsg = firstError['message'] ?? errorMsg;
          }
          CustomToast.showError(context, errorMsg);
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
    if (_isReadOnly) return;
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
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchAddress();
                await _fetchStates();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        enabled: !_isReadOnly,
                        isRequired: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 20),
                      _buildFunctionalDropdown(
                        label: 'State',
                        hint: 'Select State',
                        icon: Icons.flag_rounded,
                        value: _currStateController.text.isEmpty
                            ? null
                            : _currStateController.text,
                        items: _states.map((s) => s['name'] as String).toList(),
                        isRequired: true,
                        onChanged: _isReadOnly
                            ? null
                            : (val) {
                                setState(() {
                                  _currStateController.text = val ?? '';
                                  final state = _states.firstWhere(
                                    (s) => s['name'] == val,
                                    orElse: () => null,
                                  );
                                  if (state != null) {
                                    _selectedStateCode = state['isoCode'];
                                    _currDistrictController.clear();
                                    _fetchCities(_selectedStateCode!);
                                  }
                                });
                              },
                      ),
                      const SizedBox(height: 20),
                      _isLoadingCities
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SpinKitThreeBounce(
                                  color: OtrTheme.primaryBlue,
                                  size: 20,
                                ),
                              ),
                            )
                          : _buildFunctionalDropdown(
                              label: 'District',
                              hint: 'Select District',
                              icon: Icons.location_city_rounded,
                              value: _currDistrictController.text.isEmpty
                                  ? null
                                  : _currDistrictController.text,
                              items: _cities
                                  .map((c) => c['name'] as String)
                                  .toList(),
                              isRequired: true,
                              onChanged: _isReadOnly
                                  ? null
                                  : (val) {
                                      setState(() {
                                        _currDistrictController.text =
                                            val ?? '';
                                      });
                                    },
                            ),
                      const SizedBox(height: 20),
                      OtrTextField(
                        label: 'Taluka/City',
                        hintText: 'Taluka',
                        icon: Icons.location_on_rounded,
                        controller: _currTalukaController,
                        enabled: !_isReadOnly,
                        isRequired: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 20),
                      OtrTextField(
                        label: 'Pincode',
                        hintText: '6 digits',
                        icon: Icons.pin_drop_rounded,
                        controller: _currPincodeController,
                        keyboardType: TextInputType.number,
                        enabled: !_isReadOnly,
                        isRequired: true,
                        maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
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
                          enabled: !_isReadOnly,
                          isRequired: true,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 20),
                        _buildFunctionalDropdown(
                          label: 'State',
                          hint: 'Select State',
                          icon: Icons.flag_rounded,
                          value: _pStateController.text.isEmpty
                              ? null
                              : _pStateController.text,
                          items: _states
                              .map((s) => s['name'] as String)
                              .toList(),
                          isRequired: true,
                          onChanged: _isReadOnly
                              ? null
                              : (val) {
                                  setState(() {
                                    _pStateController.text = val ?? '';
                                    final state = _states.firstWhere(
                                      (s) => s['name'] == val,
                                      orElse: () => null,
                                    );
                                    if (state != null) {
                                      _selectedPStateCode = state['isoCode'];
                                      _pDistrictController.clear();
                                      _fetchCities(
                                        _selectedPStateCode!,
                                        isPermanent: true,
                                      );
                                    }
                                  });
                                },
                        ),
                        const SizedBox(height: 20),
                        _isLoadingCities
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SpinKitThreeBounce(
                                    color: OtrTheme.primaryBlue,
                                    size: 20,
                                  ),
                                ),
                              )
                            : _buildFunctionalDropdown(
                                label: 'District',
                                hint: 'Select District',
                                icon: Icons.location_city_rounded,
                                value: _pDistrictController.text.isEmpty
                                    ? null
                                    : _pDistrictController.text,
                                items: _cities
                                    .map((c) => c['name'] as String)
                                    .toList(),
                                isRequired: true,
                                onChanged: _isReadOnly
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _pDistrictController.text = val ?? '';
                                        });
                                      },
                              ),
                        const SizedBox(height: 20),
                        OtrTextField(
                          label: 'Taluka/City',
                          hintText: 'Taluka',
                          icon: Icons.location_on_rounded,
                          controller: _pTalukaController,
                          enabled: !_isReadOnly,
                          isRequired: true,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 20),
                        OtrTextField(
                          label: 'Pincode',
                          hintText: '6 digits',
                          icon: Icons.pin_drop_rounded,
                          controller: _pPincodeController,
                          keyboardType: TextInputType.number,
                          enabled: !_isReadOnly,
                          isRequired: true,
                          maxLength: 6,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dashboard',
                  (route) => false,
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
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isReadOnly ? 'PROCEED TO DASHBOARD' : 'FINISH OTR SETUP',
                  style: const TextStyle(
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : null,
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
              fontWeight: FontWeight.w600,
              color: OtrTheme.darkNavy,
              fontFamily: 'Inter',
            ),
            items: items.toSet().map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
