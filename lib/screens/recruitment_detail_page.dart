import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';

class RecruitmentDetailPage extends StatelessWidget {
  const RecruitmentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Receiving recruitment data via arguments
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final bool isApplied = data['isApplied'] ?? false;
    final Color statusColor = data['statusColor'] ?? Colors.blue;

    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: Text(
          isApplied ? 'Application Details' : 'Recruitment Info',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            _buildStatusHeader(data['status'], statusColor, isApplied),
            const SizedBox(height: 24),

            // Main Info Card
            _buildInfoCard(data, isApplied),
            const SizedBox(height: 24),

            // Description Section
            _buildDetailSection(
              'Job Description',
              'Responsible for developing high-quality mobile applications using Flutter. Working closely with the design and backend teams to deliver seamless user experiences and maintain high-performance code.',
            ),
            const SizedBox(height: 20),

            // Requirements Section
            _buildDetailSection(
              'Key Requirements',
              '• 3+ years of experience in Flutter development.\n'
              '• Strong understanding of Dart and state management.\n'
              '• Experience with RESTful APIs and modern architecture patterns.\n'
              '• Knowledge of CI/CD pipelines and unit testing.',
            ),
            const SizedBox(height: 32),

            // Footer Button
            ElevatedButton(
              onPressed: () {
                if (!isApplied) {
                  Navigator.pushNamed(
                    context,
                    '/apply-now',
                    arguments: {
                      'title': data['title'],
                      'organization': data['organization'],
                    },
                  );
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading receipt...')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OtrTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                isApplied ? 'Download Application Receipt' : 'Apply Now',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String status, Color color, bool isApplied) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(
              isApplied ? Icons.task_alt_rounded : Icons.info_outline_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isApplied ? 'Application Status' : 'Recruitment Status',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.withOpacity(0.7)),
              ),
              Text(
                status.toUpperCase(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> data, bool isApplied) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
          ),
          const SizedBox(height: 8),
          Text(
            data['organization'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: OtrTheme.primaryBlue),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 24),
          if (isApplied)
            _buildInfoRow(Icons.calendar_today_rounded, 'Applied Date', data['date'] ?? 'N/A')
          else
            _buildInfoRow(Icons.event_note_rounded, 'Posting Date', '20 Apr 2026'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on_outlined, 'Location', data['location'] ?? 'Mumbai, India'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.account_balance_wallet_outlined, 'Salary Range', data['salary'] ?? '₹10L - ₹20L PA'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black45),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 14, color: OtrTheme.darkNavy, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.6, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
