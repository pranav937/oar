import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class AppliedRecruitmentPage extends StatefulWidget {
  const AppliedRecruitmentPage({super.key});

  @override
  State<AppliedRecruitmentPage> createState() => _AppliedRecruitmentPageState();
}

class _AppliedRecruitmentPageState extends State<AppliedRecruitmentPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _applications = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await _apiService.getMyApplications();
      if (result['success'] == true) {
        setState(() {
          final data = result['data'];
          if (data is Map && data.containsKey('applications')) {
            _applications = data['applications'];
          } else if (data is List) {
            _applications = data;
          } else if (data is Map && data.containsKey('items')) {
            _applications = data['items'];
          } else {
            _applications = [];
          }
        });
      } else {
        setState(
          () => _error = result['message'] ?? 'Failed to load applications',
        );
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
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'My Applications',
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
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitWave(color: OtrTheme.primaryBlue, size: 30),
            )
          : _error.isNotEmpty
          ? _buildErrorPlaceholder()
          : _applications.isEmpty
          ? _buildEmptyPlaceholder()
          : RefreshIndicator(
              onRefresh: _fetchApplications,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _applications.length,
                itemBuilder: (context, index) {
                  return _buildRecruitmentCard(context, _applications[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No applications found.',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/total-recruitment'),
            child: const Text('View Available Jobs'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          Text(_error, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _fetchApplications,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitmentCard(BuildContext context, dynamic app) {
    String status = app['status'] ?? 'SUBMITTED';
    Color statusColor = OtrTheme.primaryBlue;
    if (status == 'APPROVED' || status == 'SUCCESS') statusColor = Colors.green;
    if (status == 'REJECTED' || status == 'FAILED') statusColor = Colors.red;
    if (status == 'PENDING_PAYMENT') statusColor = Colors.orange;

    String dateStr = 'N/A';
    try {
      if (app['submittedAt'] != null) {
        dateStr = DateFormat(
          'dd MMM yyyy',
        ).format(DateTime.parse(app['submittedAt']));
      } else if (app['createdAt'] != null) {
        dateStr = DateFormat(
          'dd MMM yyyy',
        ).format(DateTime.parse(app['createdAt']));
      }
    } catch (_) {}

    String appNo =
        app['applicationNumber'] ??
        (app['uuid'] ?? 'N/A').toString().substring(0, 8).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app['postName'] ?? app['postPreference1'] ?? 'Title N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: OtrTheme.darkNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app['advertisementName'] != null && app['advertisementName'].toString().isNotEmpty
                          ? app['advertisementName']
                          : 'Education Department',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status, statusColor),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCompactInfo('SUBMITTED DATE', dateStr),
              _buildCompactInfo('APPLICATION NO', appNo),
            ],
          ),
          if (status == 'PENDING_PAYMENT') ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/payment',
                  arguments: {
                    'applicationUuid': app['uuid'],
                    'amount': 500.0,
                    'title': app['postPreference1'],
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'PAY NOW - ₹500',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: OtrTheme.darkNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
