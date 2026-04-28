import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/dashboard_model.dart';
import '../utils/custom_toast.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  DashboardStats? _stats;
  int _totalFromApi = 0;
  int _pendingFromApi = 0;
  int _activeJobsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      // 1. Fetch Summary Stats
      final dashboardResult = await _apiService.getDashboard();

      // 2. Fetch Detailed Applications to refine counts
      final appsResult = await _apiService.getMyApplications(pageSize: 100);

      // 3. Fetch Jobs for New Openings count
      final jobsResult = await _apiService.getJobs();

      if (mounted) {
        setState(() {
          if (dashboardResult['success'] == true &&
              dashboardResult['data'] != null) {
            _stats = DashboardStats.fromJson(dashboardResult['data']);
          }

          if (appsResult['success'] == true && appsResult['data'] != null) {
            final data = appsResult['data'];
            List applications = [];
            if (data is Map && data.containsKey('applications')) {
              applications = data['applications'];
              _totalFromApi = data['total'] ?? applications.length;
            } else if (data is List) {
              applications = data;
              _totalFromApi = applications.length;
            }

            // Calculate pending (Draft or Pending Payment)
            _pendingFromApi = applications
                .where(
                  (app) =>
                      app['status'] == 'PENDING_PAYMENT' ||
                      app['status'] == 'DRAFT',
                )
                .length;
          }

          if (jobsResult['success'] == true && jobsResult['data'] != null) {
            final jobsData = jobsResult['data'];
            if (jobsData is List) {
              _activeJobsCount = jobsData.length;
            }
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        toolbarHeight: 70,
        title: Hero(
          tag: 'app_logo',
          child: SvgPicture.asset('assets/images/jadeE.svg', height: 60),
        ),
        centerTitle: true,
        backgroundColor: OtrTheme.surface,
        surfaceTintColor: OtrTheme.surface,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, size: 26),
            onPressed: () async {
              await _apiService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCube(color: OtrTheme.primaryBlue, size: 40),
            )
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              color: OtrTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildProfileCompletion(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Recruitment Stats'),
                    const SizedBox(height: 16),
                    _buildStatCards(),
                    const SizedBox(height: 32),
                    _DashboardSection(
                      title: 'Candidate Profile',
                      onRefresh: _fetchDashboardData,
                      items: [
                        _GridItemData(
                          'Bio Data',
                          Icons.person_outline_rounded,
                          color: Colors.blue,
                        ),
                        _GridItemData(
                          'Address Details',
                          Icons.location_on_outlined,
                          color: Colors.orange,
                        ),
                        _GridItemData(
                          'Upload Documents',
                          Icons.description_outlined,
                          color: Colors.purple,
                        ),
                        _GridItemData(
                          'Account Status',
                          Icons.verified_user_outlined,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _DashboardSection(
                      title: 'Application Services',
                      onRefresh: _fetchDashboardData,
                      items: [
                        _GridItemData(
                          'New Openings',
                          Icons.business_center_outlined,
                          color: Colors.indigo,
                        ),
                        _GridItemData(
                          'My Applications',
                          Icons.history_edu_rounded,
                          color: Colors.teal,
                        ),
                        _GridItemData(
                          'Payment History',
                          Icons.account_balance_wallet_outlined,
                          color: Colors.amber,
                        ),
                        _GridItemData(
                          'Admit Card',
                          Icons.badge_rounded,
                          color: Colors.pink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCompletion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OtrTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: OtrTheme.darkNavy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OtrTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '85%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: OtrTheme.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.85,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(OtrTheme.success),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              Text(
                'Complete documents to reach 100%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final name = _stats?.fullName ?? 'Candidate';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: OtrTheme.darkGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: OtrTheme.darkNavy.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: _stats?.photoUrl != null
                            ? Image.network(
                                _stats!.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => _buildInitial(name),
                              )
                            : _buildInitial(name),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: OtrTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _stats?.registrationId ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _stats?.category ?? 'General Category',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      _buildInfoItem(
                        Icons.alternate_email_rounded,
                        _stats?.email ?? 'N/A',
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      _buildInfoItem(
                        Icons.phone_android_rounded,
                        _stats?.mobileNumber ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitial(String name) {
    return Container(
      color: OtrTheme.primaryBlue.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'C',
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: OtrTheme.mediumBlue),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: OtrTheme.darkNavy,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    final totalApplications =
        (_stats?.totalApplications != null && _stats!.totalApplications > 0)
        ? _stats!.totalApplications
        : _totalFromApi;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'New Openings',
            subtitle: 'Active Jobs',
            count: _activeJobsCount.toString(),
            color: OtrTheme.primaryBlue,
            icon: Icons.business_center_rounded,
            onTap: () => Navigator.pushNamed(context, '/total-recruitment'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'My Applications',
            subtitle: 'Total Applied',
            count: totalApplications.toString(),
            color: OtrTheme.success,
            icon: Icons.assignment_turned_in_rounded,
            onTap: () => Navigator.pushNamed(context, '/applied-recruitment'),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String count;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: OtrTheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: OtrTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Icon(
                  Icons.trending_up_rounded,
                  color: color.withValues(alpha: 0.3),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: OtrTheme.darkNavy,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: OtrTheme.darkNavy,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridItemData {
  final String title;
  final IconData icon;
  final Color color;
  _GridItemData(this.title, this.icon, {required this.color});
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final List<_GridItemData> items;
  final VoidCallback? onRefresh;

  const _DashboardSection({
    required this.title,
    required this.items,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: OtrTheme.darkNavy,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              onTap: () async {
                final t = item.title;
                if (t == 'Bio Data') {
                  await Navigator.pushNamed(context, '/bio');
                } else if (t == 'Address Details') {
                  await Navigator.pushNamed(context, '/address');
                } else if (t == 'Upload Documents') {
                  await Navigator.pushNamed(context, '/documents');
                } else if (t == 'New Openings') {
                  await Navigator.pushNamed(context, '/total-recruitment');
                } else if (t == 'My Applications') {
                  await Navigator.pushNamed(context, '/applied-recruitment');
                } else if (t == 'Payment History') {
                  await Navigator.pushNamed(context, '/payment');
                } else if (t == 'Account Status') {
                  await Navigator.pushNamed(context, '/status');
                } else if (t == 'Admit Card') {
                  if (context.mounted) {
                    CustomToast.showSuccess(
                      context,
                      'Admit Card module coming soon!',
                    );
                  }
                }
                onRefresh?.call();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: OtrTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: OtrTheme.softShadow,
                  border: Border.all(
                    color: item.color.withValues(alpha: 0.05),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: OtrTheme.darkNavy,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
