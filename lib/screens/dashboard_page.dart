import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/dashboard_model.dart';

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

      if (mounted) {
        setState(() {
          if (dashboardResult['success'] == true && dashboardResult['data'] != null) {
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
            _pendingFromApi = applications.where((app) => 
               app['status'] == 'PENDING_PAYMENT' || app['status'] == 'DRAFT'
            ).length;
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
        title: SvgPicture.asset('assets/images/jadeE.svg', height: 38),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await _apiService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitDoubleBounce(color: OtrTheme.primaryBlue),
            )
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildContactBar(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Application Overview'),
                    const SizedBox(height: 16),
                    _buildStatCards(),
                    const SizedBox(height: 32),
                    _DashboardSection(
                      title: 'Registration & Profile',
                      onRefresh: _fetchDashboardData,
                      items: [
                        _GridItemData('Bio', Icons.person_pin_rounded),
                        _GridItemData('Address', Icons.home_work_rounded),
                        _GridItemData('Documents', Icons.file_present_outlined),
                        _GridItemData('Profile', Icons.account_box_outlined),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _DashboardSection(
                      title: 'Applications',
                      onRefresh: _fetchDashboardData,
                      items: [
                        _GridItemData(
                          'New Job',
                          Icons.assignment_turned_in_outlined,
                        ),
                        _GridItemData('My Apps', Icons.list_alt_rounded),
                        _GridItemData('Payment', Icons.payment_rounded),
                        _GridItemData('Results', Icons.fact_check_outlined),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    final name = _stats?.fullName ?? 'Candidate';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [OtrTheme.darkNavy, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: OtrTheme.darkNavy.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: _stats?.photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.network(_stats!.photoUrl!, fit: BoxFit.cover),
                  )
                : Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: OtrTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _stats?.registrationId ?? 'ID-PENDING',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Category: ${_stats?.category ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _stats?.registrationStatus == 'ACTIVE'
                  ? Colors.green
                  : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _stats?.registrationStatus == 'ACTIVE'
                  ? Icons.check
                  : Icons.access_time_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildContactItem(Icons.email_outlined, _stats?.email ?? 'N/A'),
          Container(width: 1, height: 20, color: Colors.grey.shade200),
          _buildContactItem(
            Icons.phone_iphone_rounded,
            _stats?.mobileNumber ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: OtrTheme.mediumBlue),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: OtrTheme.darkNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: OtrTheme.darkNavy,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildStatCards() {
    // Priority to calculated counts if non-zero, else use stats from dashboard summary
    final total = _totalFromApi > 0 ? _totalFromApi : (_stats?.totalApplications ?? 0);
    final pending = _pendingFromApi > 0 ? _pendingFromApi : (_stats?.pendingApplications ?? 0);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Applications',
            count: total.toString(),
            color: OtrTheme.primaryBlue,
            icon: Icons.assignment_turned_in_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Pending Apps',
            count: pending.toString(),
            color: Colors.orange,
            icon: Icons.pending_actions_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            count,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridItemData {
  final String title;
  final IconData icon;
  final String? route;
  _GridItemData(this.title, this.icon, {this.route});
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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: OtrTheme.softShadow,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.75, // Slightly taller for text breathing room
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () async {
                  if (item.route != null) {
                    await Navigator.pushNamed(context, item.route!);
                    onRefresh?.call();
                  } else {
                    final t = item.title;
                    if (t == 'Bio') {
                      await Navigator.pushNamed(context, '/bio');
                      onRefresh?.call();
                    } else if (t == 'Address') {
                      await Navigator.pushNamed(context, '/address');
                      onRefresh?.call();
                    } else if (t == 'Documents') {
                      await Navigator.pushNamed(context, '/documents');
                      onRefresh?.call();
                    } else if (t == 'New Job') {
                      await Navigator.pushNamed(context, '/total-recruitment');
                      onRefresh?.call();
                    } else if (t == 'My Apps') {
                      await Navigator.pushNamed(
                        context,
                        '/applied-recruitment',
                      );
                      onRefresh?.call();
                    } else if (t == 'Payment') {
                      await Navigator.pushNamed(context, '/payment');
                      onRefresh?.call();
                    } else if (t == 'Profile') {
                      await Navigator.pushNamed(context, '/status');
                      onRefresh?.call();
                    }
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: OtrTheme.background.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.icon,
                        color: OtrTheme.primaryBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
