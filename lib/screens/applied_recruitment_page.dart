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
          _applications = result['data'];
        });
      } else {
        setState(() => _error = result['message'] ?? 'Failed to load applications');
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
          ? const Center(child: SpinKitWave(color: OtrTheme.primaryBlue, size: 30))
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
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No applications found.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
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
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(_error, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          TextButton(onPressed: _fetchApplications, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildRecruitmentCard(BuildContext context, dynamic app) {
    String status = app['status'] ?? 'SUBMITTED';
    Color statusColor = Colors.blue;
    if (status == 'APPROVED') statusColor = Colors.green;
    if (status == 'REJECTED') statusColor = Colors.red;
    if (status == 'PENDING_PAYMENT') statusColor = Colors.orange;

    String dateStr = app['createdAt'] != null 
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(app['createdAt']))
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app['advertisement']?['postName'] ?? app['postPreference1'] ?? 'Application',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
                    ),
                    Text(
                      app['advertisement']?['departmentName'] ?? 'Department',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Applied: $dateStr', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              if (status == 'PENDING_PAYMENT')
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/payment', arguments: {
                      'applicationUuid': app['uuid'],
                      'amount': 500.0,
                      'title': app['postPreference1'],
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              else
                TextButton(
                  onPressed: () {},
                  child: const Text('View Status', style: TextStyle(fontWeight: FontWeight.bold, color: OtrTheme.primaryBlue)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
