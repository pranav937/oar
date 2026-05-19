import 'package:flutter/material.dart';
import '../../theme/otr_theme.dart';
import '../../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await _apiService.getVendorProfile();
      if (result['success'] == true) {
        setState(() => _profile = result['data']);
      } else {
        setState(() => _error = result['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      setState(() => _error = 'An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Vendor Profile',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.8),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: OtrTheme.darkNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCube(color: OtrTheme.primaryBlue, size: 40),
            )
          : _error.isNotEmpty
          ? _buildErrorPlaceholder()
          : RefreshIndicator(
              onRefresh: _fetchProfile,
              color: OtrTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildPremiumHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileSummary(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('CONTACT INFORMATION'),
                          _buildContactCard(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('CORPORATE CREDENTIALS'),
                          _buildCorporateCard(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('PARTNER INSIGHTS'),
                          _buildMilestoneCard(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('BANKING DETAILS'),
                          _buildBankCard(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('TECHNICAL CAPABILITIES'),
                          _buildCapabilitiesCard(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('REGISTERED ADDRESSES'),
                          _buildAddressCard(
                            'REGISTERED OFFICE',
                            _profile!['registeredAddress'],
                          ),
                          const SizedBox(height: 12),
                          _buildAddressCard(
                            'OFFICE ADDRESS',
                            _profile!['officeAddress'],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPremiumHeader() {
    final data = _profile!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: OtrTheme.primaryBlue.withValues(alpha: 0.1),
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: OtrTheme.primaryBlue,
                  child: Text(
                    data['legalName'].substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data['legalName'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['vendorCode'],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.blue,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderBadge('ONBOARDED', 'May 2026'),
              const SizedBox(width: 12),
              _buildHeaderBadge('RATING', 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: OtrTheme.darkNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary() {
    return Container(
      transform: Matrix4.translationValues(0, -20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OtrTheme.primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.intenseShadow,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.business_center_rounded,
            color: Colors.white70,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile!['category']?.toString().replaceAll('_', ' ') ??
                      'CATEGORY',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  _profile!['tradeName'] ?? 'Trade Name',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildSmallBadge(
            _profile!['status'] ?? 'ONBOARDED',
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.blueGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.person_outline_rounded,
            'Contact Person',
            _profile!['contactPerson'],
            sub: _profile!['designation'],
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.alternate_email_rounded,
            'Email Address',
            _profile!['contactEmail'],
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.phone_iphone_rounded,
            'Phone Number',
            _profile!['contactPhone'],
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.language_rounded,
            'Website',
            _profile!['website'],
            isBlue: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildDataRow('CIN Number', _profile!['cinNumber'] ?? 'N/A'),
          _buildDataRow('PAN Number', _profile!['pan']),
          _buildDataRow('GSTIN', _profile!['gstin']),
          _buildDataRow('Reg Type', _profile!['registrationType']),
          _buildDataRow(
            'Incorporation',
            _formatDateShort(_profile!['dateOfIncorporation']),
          ),
          _buildDataRow(
            'Business Years',
            '${_profile!['yearsInBusiness']} Years',
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [OtrTheme.darkNavy, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: OtrTheme.intenseShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ANNUAL TURNOVER',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white38,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.greenAccent,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_profile!['annualTurnover']} Cr',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMilestoneStat(
                Icons.groups_rounded,
                '${_profile!['teamSize']}',
                'Experts',
              ),
              const SizedBox(width: 32),
              _buildMilestoneStat(
                Icons.assignment_turned_in_rounded,
                '${_profile!['similarProjectsExecuted']}+',
                'Projects',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white24, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildDataRow('Bank Name', _profile!['bankName'] ?? 'N/A'),
          _buildDataRow('IFSC Code', _profile!['ifscCode'] ?? 'N/A'),
          _buildDataRow('Account No.', 'XXXX-XXXX-XXXX', isMasked: true),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTagSection(
            'CORE TECHNOLOGY STACK',
            _profile!['technologyStack'],
          ),
          const SizedBox(height: 16),
          _buildTagSection(
            'INFRASTRUCTURE',
            _profile!['infrastructureDetails'],
          ),
          const SizedBox(height: 16),
          _buildTagSection('CERTIFICATIONS', _profile!['certifications']),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.redAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: OtrTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: OtrTheme.darkNavy,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    String? sub,
    bool isBlue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: OtrTheme.primaryBlue.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isBlue ? Colors.blue : OtrTheme.darkNavy,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isMasked = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: OtrTheme.darkNavy,
                fontWeight: FontWeight.w900,
                letterSpacing: isMasked ? 2 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() => const Divider(height: 1, color: Color(0xFFF1F5F9));

  Widget _buildSmallBadge(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: (color ?? Colors.blue),
        ),
      ),
    );
  }

  String _formatDateShort(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: OtrTheme.error,
          ),
          const SizedBox(height: 16),
          Text(_error),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchProfile, child: const Text('Retry')),
        ],
      ),
    );
  }
}
