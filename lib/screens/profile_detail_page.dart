import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/custom_toast.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({super.key});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await _apiService.getProfile();
      if (result['success'] == true) {
        setState(() {
          _profileData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          CustomToast.showSuccess(context, result['message'] ?? 'Failed to load profile');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        
        body: Center(child: SpinKitDoubleBounce(color: OtrTheme.primaryBlue)),
      );
    }

    final p = _profileData ?? {};

    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Profile Details',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/bio'),
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: const Text(
              'EDIT',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
            style: TextButton.styleFrom(foregroundColor: OtrTheme.primaryBlue),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              _buildProfileHeader(p),
              const SizedBox(height: 24),
              _buildStatusSection(p),
              const SizedBox(height: 24),
              _buildSectionHeader('Personal Information', Icons.person_rounded),
              _buildInfoTable([
                _InfoRow(
                  'Name',
                  '${p['firstName'] ?? ''} ${p['middleName'] ?? ''} ${p['lastName'] ?? ''}'
                      .trim(),
                ),
                _InfoRow('Father\'s Name', p['fatherName'] ?? 'N/A'),
                _InfoRow('Mother\'s Name', p['motherName'] ?? 'N/A'),
                _InfoRow('Phone', p['mobileNumber'] ?? 'N/A'),
                _InfoRow('e-Mail', p['email'] ?? 'N/A'),
                _InfoRow('Date of Birth', p['dateOfBirth'] ?? 'DD/MM/YYYY'),
                _InfoRow('Gender', p['gender'] ?? 'N/A'),
                _InfoRow('Nationality', p['nationality'] ?? 'N/A'),
                _InfoRow('Aadhaar No.', p['aadhaarNumber'] ?? 'N/A'),
                _InfoRow('Registration ID', p['registrationId'] ?? 'N/A'),
              ]),
              const SizedBox(height: 32),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  CustomToast.showSuccess(context, 'Profile submitted for verification!');
                },
                child: const Text(
                  'Submit For Verification',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> p) {
    final name = '${p['firstName'] ?? ''} ${p['lastName'] ?? 'Candidate'}'
        .trim();
    String? photoUrl = p['photoUrl'];
    if (photoUrl != null && !photoUrl.startsWith('http')) {
      photoUrl =
          '${ApiConstants.baseUrl}${photoUrl.startsWith('/') ? '' : '/'}$photoUrl';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: OtrTheme.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: OtrTheme.primaryBlue.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_outline_rounded,
                        size: 45,
                        color: OtrTheme.primaryBlue,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person_outline_rounded,
                    size: 45,
                    color: OtrTheme.primaryBlue,
                  ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: OtrTheme.darkNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ID: ${p['registrationId'] ?? 'PENDING'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blueAccent,
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

  Widget _buildStatusSection(Map<String, dynamic> p) {
    final status = p['registrationStatus'] ?? 'DRAFT';
    final bool isActive = status == 'ACTIVE';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green.shade300 : Colors.amber.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade200 : Colors.amber.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: isActive ? Colors.green.shade900 : Colors.brown,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'STATUS: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: OtrTheme.darkNavy,
              fontSize: 16,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.green : Colors.orange,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, color: OtrTheme.primaryBlue, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: OtrTheme.darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTable(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: rows.map((row) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.05)),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      row.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: OtrTheme.darkNavy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow(this.label, this.value);
}
