import 'package:flutter/material.dart';
import '../../theme/otr_theme.dart';
import '../../services/api_service.dart';

class VendorDashboardPage extends StatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.getVendorProfile();
      if (result['success'] == true) {
        setState(() => _profileData = result['data']);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', height: 40),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: OtrTheme.darkNavy,
              size: 28,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.power_settings_new_rounded,
              color: OtrTheme.darkNavy,
              size: 28,
            ),
            onPressed: () async {
              await _apiService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        color: OtrTheme.primaryBlue,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVendorProfileCard(),
              const SizedBox(height: 32),
              _buildSectionTitle('BUSINESS INSIGHTS'),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _statusCard(
                    '9',
                    'Active Bids',
                    'Submitted',
                    Icons.work_outline_rounded,
                    const Color(0xFFE0F2FE),
                  ),
                  _statusCard(
                    '5',
                    'Opportunities',
                    'Open Now',
                    Icons.campaign_outlined,
                    const Color(0xFFDCFCE7),
                  ),
                  _statusCard(
                    '2',
                    'Pending Invoices',
                    'Wait for Payment',
                    Icons.currency_rupee_rounded,
                    const Color(0xFFFEF9C3),
                  ),
                  _statusCard(
                    '4.8',
                    'Performance',
                    'Top Rated',
                    Icons.trending_up_rounded,
                    const Color(0xFFF3E8FF),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('MANAGEMENT'),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _serviceCard(
                    'Open EOIs',
                    'View Openings',
                    Icons.campaign_rounded,
                    const Color(0xFFE0F2FE),
                    Colors.blue,
                    onTap: () =>
                        Navigator.pushNamed(context, '/vendor-open-eois'),
                  ),
                  _serviceCard(
                    'My Bids',
                    'View Status',
                    Icons.gavel_rounded,
                    const Color(0xFFFFF7ED),
                    Colors.orange,
                    onTap: () =>
                        Navigator.pushNamed(context, '/vendor-my-bids'),
                  ),
                  _serviceCard(
                    'Profile',
                    'View Profile',
                    Icons.person_outline_rounded,
                    const Color(0xFFECFDF5),
                    Colors.green,
                    onTap: () =>
                        Navigator.pushNamed(context, '/vendor-profile'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('OPERATIONAL SERVICES'),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _serviceCard(
                    'Invoices & Payments',
                    'View History',
                    Icons.receipt_long_outlined,
                    const Color(0xFFFEFCE8),
                    Colors.amber,
                    onTap: () =>
                        Navigator.pushNamed(context, '/vendor-finance'),
                  ),
                  _serviceCard(
                    'Work Orders',
                    'View Status',
                    Icons.assignment_outlined,
                    const Color(0xFFFFF1F2),
                    Colors.pink,
                    onTap: () =>
                        Navigator.pushNamed(context, '/vendor-work-orders'),
                  ),
                  _serviceCard(
                    'Performance',
                    'View Rating',
                    Icons.trending_up_rounded,
                    const Color(0xFFF0FDFA),
                    Colors.teal,
                    onTap: () =>
                        Navigator.pushNamed(context, '/vendor-performance'),
                  ),
                  _serviceCard(
                    'Documents',
                    'View Vault',
                    Icons.folder_open_rounded,
                    const Color(0xFFEFF6FF),
                    Colors.indigo,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: OtrTheme.darkNavy,
      ),
    );
  }

  Widget _buildVendorProfileCard() {
    if (_isLoading) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: OtrTheme.darkNavy,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final data = _profileData ?? {};
    final legalName = data['legalName'] ?? 'Vendor Name';
    final vendorCode = data['vendorCode'] ?? 'VND-000000';
    final email = data['contactEmail'] ?? 'contact@vendor.com';
    final phone = data['contactPhone'] ?? '0000000000';
    final category =
        data['category']?.toString().replaceAll('_', ' ') ?? 'CATEGORY';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OtrTheme.darkNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: OtrTheme.darkNavy.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://ui-avatars.com/api/?name=$legalName&background=1C4D8D&color=fff',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vendorCode,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      legalName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.alternate_email_rounded,
                  color: Colors.white38,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.phone_iphone_rounded,
                  color: Colors.white38,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  phone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(
    String count,
    String title,
    String sub,
    IconData icon,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: OtrTheme.darkNavy),
          ),
          const Spacer(),
          Text(
            count,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
              letterSpacing: -1,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
            ),
          ),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(
    String title,
    String sub,
    IconData icon,
    Color bg,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: OtrTheme.darkNavy,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
