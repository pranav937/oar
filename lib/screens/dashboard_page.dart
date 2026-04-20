import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String _userName = 'Candidate';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final result = await _apiService.getDashboard();
      if (result['success'] == true) {
        setState(() {
          _stats = result['data'];
          _userName = _stats?['candidateName'] ?? 'Candidate';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'OTR Portal',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
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
          ? const Center(child: SpinKitDoubleBounce(color: OtrTheme.primaryBlue))
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $_userName',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
                    ),
                    const Text(
                      'Manage your registrations and applications here.',
                      style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),

                    _buildStatCards(),
                    const SizedBox(height: 32),

                    _DashboardSection(
                      title: 'Registration & Profile',
                      items: [
                        _GridItemData('Bio', Icons.person_outline_rounded),
                        _GridItemData('Address', Icons.map_outlined),
                        _GridItemData('Documents', Icons.file_present_outlined),
                        _GridItemData('Education', Icons.school_outlined),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _DashboardSection(
                      title: 'Applications',
                      items: [
                        _GridItemData('New Job', Icons.assignment_turned_in_outlined),
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

  Widget _buildStatCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(
            title: 'Active Jobs',
            count: _stats?['activeAdvertisementsCount']?.toString() ?? '0',
            color: OtrTheme.primaryBlue,
            icon: Icons.work_outline,
          ),
          const SizedBox(width: 16),
          _StatCard(
            title: 'Applications',
            count: _stats?['myApplicationsCount']?.toString() ?? '0',
            color: Colors.green,
            icon: Icons.description_outlined,
          ),
          const SizedBox(width: 16),
          _StatCard(
            title: 'Approved',
            count: '2',
            color: Colors.orange,
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.count, required this.color, required this.icon});

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
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
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

  const _DashboardSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy, letterSpacing: -0.2),
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
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () {
                  if (item.route != null) {
                    Navigator.pushNamed(context, item.route!);
                  } else {
                    final t = item.title;
                    if (t == 'Bio') Navigator.pushNamed(context, '/bio');
                    else if (t == 'Address') Navigator.pushNamed(context, '/address');
                    else if (t == 'Documents') Navigator.pushNamed(context, '/documents');
                    else if (t == 'New Job') Navigator.pushNamed(context, '/total-recruitment');
                    else if (t == 'My Apps') Navigator.pushNamed(context, '/applied-recruitment');
                    else if (t == 'Payment') Navigator.pushNamed(context, '/payment');
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
                      child: Icon(item.icon, color: OtrTheme.primaryBlue, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black87),
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
