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
  String _selectedFilter = 'ALL';


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
      final result = await _apiService.getMyApplications(
        pageSize: 20,
        status: _selectedFilter,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          final data = result['data'];
          List<dynamic> fetchedApps = [];
          if (data is Map && data.containsKey('applications')) {
            fetchedApps = data['applications'];
          } else if (data is List) {
            fetchedApps = data;
          } else if (data is Map && data.containsKey('items')) {
            fetchedApps = data['items'];
          }

          if (_selectedFilter == 'ALL') {
            _applications = fetchedApps;
          } else {
            _applications = fetchedApps.where((app) {
              final status = (app['status'] ?? '').toString().toUpperCase();
              if (_selectedFilter == 'APPROVED') {
                return status == 'APPROVED' ||
                    status == 'SUCCESS' ||
                    status == 'ACCEPTED' ||
                    status == 'ADMIT_CARD_ISSUED' ||
                    status == 'APPROVE_FOR_EXAM' ||
                    status == 'APPROVED_FOR_EXAM';
              }
              if (_selectedFilter == 'SUBMITTED') {
                // Payment-completed applications are logically "submitted"
                return status == 'SUBMITTED' ||
                    status == 'PAYMENT_COMPLETED' ||
                    status == 'PAID' ||
                    status == 'PAYMENT_VERIFIED' ||
                    status == 'PAYMENT_SUCCESS';
              }
              return status == _selectedFilter;
            }).toList();
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
        backgroundColor: OtrTheme.surface,
        surfaceTintColor: OtrTheme.surface,
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
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: _applications.isEmpty
                      ? _buildEmptyPlaceholder()
                      : RefreshIndicator(
                          onRefresh: _fetchApplications,
                          color: OtrTheme.primaryBlue,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _applications.length,
                            itemBuilder: (context, index) {
                              return _buildRecruitmentCard(
                                context,
                                _applications[index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFilterChip('ALL')),
              const SizedBox(width: 10),
              Expanded(child: _buildFilterChip('SUBMITTED')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildFilterChip('APPROVED')),
              const SizedBox(width: 10),
              Expanded(child: _buildFilterChip('REJECTED')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = filter == _selectedFilter;
    return ChoiceChip(
      label: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          filter,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : OtrTheme.darkNavy,
            fontSize: 12,
          ),
        ),
      ),
      selected: isSelected,
      selectedColor: OtrTheme.primaryBlue,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? OtrTheme.primaryBlue : Colors.grey.shade300,
        ),
      ),
      onSelected: (selected) {
        if (!isSelected) {
          setState(() => _selectedFilter = filter);
          _fetchApplications();
        }
      },
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: OtrTheme.softShadow,
            ),
            child: Icon(
              Icons.assignment_late_outlined,
              size: 50,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No applications found.',
            style: TextStyle(
              color: OtrTheme.darkNavy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't applied for any jobs yet.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/total-recruitment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: OtrTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('EXPLORE JOBS'),
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
            color: OtrTheme.error,
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
    String rawStatus = (app['status'] ?? 'SUBMITTED').toString().toUpperCase();

    bool isAdmitCardIssued = false;
    if (app['statusTimeline'] != null && app['statusTimeline'] is Map) {
      isAdmitCardIssued = app['statusTimeline']['admitCardIssued'] == true;
    }

    // Normalize payment-completed states to SUBMITTED for display
    String status = rawStatus;
    if (isAdmitCardIssued) {
      status = 'ADMIT_CARD_ISSUED';
    } else if (rawStatus == 'PAYMENT_COMPLETED' ||
        rawStatus == 'PAID' ||
        rawStatus == 'PAYMENT_VERIFIED' ||
        rawStatus == 'PAYMENT_SUCCESS') {
      status = 'SUBMITTED';
    }

    Color statusColor = OtrTheme.primaryBlue;
    if (status == 'APPROVED' ||
        status == 'SUCCESS' ||
        status == 'ACCEPTED' ||
        status == 'ADMIT_CARD_ISSUED' ||
        status == 'APPROVE_FOR_EXAM' ||
        status == 'APPROVED_FOR_EXAM') {
      statusColor = OtrTheme.success;
    }
    if (status == 'REJECTED' || status == 'FAILED') {
      statusColor = OtrTheme.error;
    }
    if (status == 'PENDING_PAYMENT') {
      statusColor = OtrTheme.warning;
    }

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
      decoration: BoxDecoration(
        color: OtrTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
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
                            app['postName'] ??
                                app['postPreference1'] ??
                                'Title N/A',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: OtrTheme.darkNavy,
                              letterSpacing: -0.5,
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
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: OtrTheme.dividerColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildCompactInfo(
                        'SUBMITTED ON',
                        dateStr,
                        Icons.event_note_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCompactInfo(
                        'APPLICATION ID',
                        appNo,
                        Icons.fingerprint_rounded,
                      ),
                    ),
                  ],
                ),
                if (rawStatus == 'PENDING_PAYMENT') ...[
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: OtrTheme.warning.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
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
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment_rounded, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'COMPLETE PAYMENT - ₹500',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildCompactInfo(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: OtrTheme.darkNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    // Display-friendly label
    String label;
    switch (status) {
      case 'SUBMITTED':
        label = '✓ SUBMITTED';
        break;
      case 'APPROVED':
      case 'SUCCESS':
      case 'ACCEPTED':
      case 'APPROVE_FOR_EXAM':
      case 'APPROVED_FOR_EXAM':
        label = '✓ APPROVED';
        break;
      case 'ADMIT_CARD_ISSUED':
        label = '✓ ADMIT CARD ISSUED';
        break;
      case 'REJECTED':
      case 'FAILED':
        label = '✗ REJECTED';
        break;
      case 'PENDING_PAYMENT':
        label = '⚠ PENDING PAYMENT';
        break;
      default:
        label = status.replaceAll('_', ' ');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
