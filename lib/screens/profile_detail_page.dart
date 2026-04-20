import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text('Profile Details', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            // Profile Header Card (More Visible)
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Status Badge (Highly Visible)
            _buildStatusSection(),
            const SizedBox(height: 24),

            // Personal Information Table (Better Contrast)
            _buildSectionHeader('Personal Information', Icons.person_rounded),
            _buildInfoTable([
              _InfoRow('Name', 'PRANAV PIPALIYA'),
              _InfoRow('Father\'s Name', 'N/A'),
              _InfoRow('Mother\'s Name', 'N/A'),
              _InfoRow('Phone', '9106999252'),
              _InfoRow('e-Mail', 'pranav@jadequest.com'),
              _InfoRow('Date of Birth', 'DD/MM/YYYY'),
              _InfoRow('Gender', 'Male'),
              _InfoRow('Religion', 'Hindu'),
              _InfoRow('Community', 'General'),
              _InfoRow('Nationality', 'Indian'),
              _InfoRow('Aadhaar No.', '0000 0000 0000'),
              _InfoRow('Qualification', 'Graduate'),
            ]),

            const SizedBox(height: 32),

            // Address Section (Standardized)
            _buildSectionHeader('Permanent Address', Icons.location_on_rounded),
            _buildInfoTable([
              _InfoRow('House No.', 'N/A'),
              _InfoRow('Street', 'N/A'),
              _InfoRow('Locality', 'N/A'),
              _InfoRow('District', 'N/A'),
              _InfoRow('State / UT', 'N/A'),
            ]),

            const SizedBox(height: 32),

            // Action History (Timeline Style)
            _buildSectionHeader('Action History', Icons.history_edu_rounded),
            _buildHistoryTimeline(),

            const SizedBox(height: 40),

            // Info Note (Alert Style)
            _buildNoteSection(),
            
            const SizedBox(height: 32),

            // Final Submit Button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile submitted for verification!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OtrTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: const Text('Submit For Verification', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: OtrTheme.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: OtrTheme.primaryBlue.withValues(alpha: 0.1), width: 2),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 45, color: OtrTheme.primaryBlue),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PRANAV PIPALIYA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: OtrTheme.darkNavy, letterSpacing: -0.5)),
                SizedBox(height: 6),
                Text('ID: MPSC-OTR-2024', style: TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.amber.shade200, shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.brown, size: 20),
          ),
          const SizedBox(width: 16),
          const Text('STATUS: ', style: TextStyle(fontWeight: FontWeight.bold, color: OtrTheme.darkNavy, fontSize: 16)),
          const Text('DRAFT', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 18, decoration: TextDecoration.underline)),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: OtrTheme.darkNavy)),
        ],
      ),
    );
  }

  Widget _buildInfoTable(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final bool isLast = index == rows.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey.withValues(alpha: 0.05))),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 130, // Increased width for better visibility
                    child: Text(row.label, style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold)),
                  ),
                  const Text(':', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(row.value, style: const TextStyle(fontSize: 14, color: OtrTheme.darkNavy, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHistoryTimeline() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_toggle_off_rounded, color: Colors.grey, size: 18),
              const SizedBox(width: 10),
              Text('Commission Action History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 14, color: Colors.blueAccent),
                  Container(width: 2, height: 40, color: Colors.blueAccent.withValues(alpha: 0.2)),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('17/Apr/2026 10:10 AM', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Status: DRAFT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy)),
                  const Text('Profile incomplete', style: TextStyle(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blue.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Text('Important Note', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.blue.shade900)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Complete all personal, permanent, and communication address details before submitting for verification.',
            style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Incomplete profiles may be rejected. Accurate information prevents delays in your job applications.',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow(this.label, this.value);
}
