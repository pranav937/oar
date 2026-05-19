import 'package:flutter/material.dart';
import '../../theme/otr_theme.dart';
import '../../services/api_service.dart';
import '../../models/vendor/vendor_performance_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class VendorPerformancePage extends StatefulWidget {
  const VendorPerformancePage({super.key});

  @override
  State<VendorPerformancePage> createState() => _VendorPerformancePageState();
}

class _VendorPerformancePageState extends State<VendorPerformancePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  VendorPerformanceModel? _performance;
  String _error = '';
  int _selectedLogIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchPerformance();
  }

  Future<void> _fetchPerformance() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await _apiService.getVendorPerformance();
      if (result['success'] == true) {
        setState(() {
          _performance = VendorPerformanceModel.fromJson(result['data'] ?? {});
        });
      } else {
        setState(
          () => _error = result['message'] ?? 'Failed to load performance data',
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;

    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Performance Analytics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: OtrTheme.darkNavy,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop) _buildLeftSidebar(),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildTopBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: SpinKitPulse(
                            color: OtrTheme.primaryBlue,
                            size: 50,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchPerformance,
                          color: OtrTheme.primaryBlue,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 60 : 16,
                              vertical: isDesktop ? 40 : 20,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPageHeader(isDesktop),
                                SizedBox(height: isDesktop ? 40 : 24),
                                _buildMetricsSection(isDesktop),
                                SizedBox(height: isDesktop ? 40 : 32),
                                _buildHistoryCard(
                                  _performance?.evaluationLog ?? [],
                                  isDesktop,
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Analytics',
                    style: TextStyle(
                      fontSize: isDesktop ? 32 : 24,
                      fontWeight: FontWeight.w900,
                      color: OtrTheme.darkNavy,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop) _buildDateButton(),
          ],
        ),
        if (!isDesktop) ...[const SizedBox(height: 16), _buildDateButton()],
      ],
    );
  }

  Widget _buildDateButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: OtrTheme.darkNavy,
          ),
          const SizedBox(width: 8),
          const Text(
            '18 MAY 2026',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(bool isDesktop) {
    int totalReviews = _performance?.evaluationLog.length ?? 0;
    if (totalReviews == 0) totalReviews = 2; // Default for design

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'TOTAL REVIEWS',
            '$totalReviews',
            'EVALUATIONS',
            Icons.inbox_rounded,
            const Color(0xFF38BDF8),
            isDesktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'AVERAGE SCORE',
            '4.69',
            '/ 5.0',
            Icons.star_border_rounded,
            const Color(0xFF10B981),
            isDesktop,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String suffix,
    IconData icon,
    Color iconColor,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: isDesktop ? 24 : 20),
              ),
              if (isDesktop)
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: OtrTheme.darkNavy,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          if (!isDesktop) ...[
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: OtrTheme.darkNavy,
                letterSpacing: 0.5,
              ),
            ),
          ],
          SizedBox(height: isDesktop ? 24 : 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.w900,
                  color: OtrTheme.darkNavy,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(bottom: isDesktop ? 6 : 4),
                child: Text(
                  suffix,
                  style: TextStyle(
                    fontSize: isDesktop ? 10 : 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueGrey.shade400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(List<KpiLogItem> data, bool isDesktop) {
    List<Map<String, dynamic>> items = data.isEmpty
        ? [
            {
              'title': 'UPSC EXAM SUPERVISION',
              'score': '4.3',
              'date': '15 MAY 2026',
            },
            {'title': 'HANDLE CCTV', 'score': '5.0', 'date': '15 MAY 2026'},
          ]
        : data
              .map((e) => {'title': e.metric, 'score': e.score, 'date': e.date})
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 32, right: 32),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('PROJECT SCOPE', style: _headerStyle()),
                ),
                Expanded(
                  flex: 2,
                  child: Text('COMPOSITE SCORE', style: _headerStyle()),
                ),
                Expanded(flex: 2, child: Text('DATE', style: _headerStyle())),
                Expanded(
                  flex: 1,
                  child: Text(
                    'ACTION',
                    textAlign: TextAlign.right,
                    style: _headerStyle(),
                  ),
                ),
              ],
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildTableRow(
              item['title'] as String,
              item['score'] as String,
              item['date'] as String,
              isDesktop,
              index,
            );
          },
        ),
      ],
    );
  }

  TextStyle _headerStyle() {
    return const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w900,
      color: OtrTheme.darkNavy,
      letterSpacing: 1,
    );
  }

  Widget _buildTableRow(
    String title,
    String score,
    String date,
    bool isDesktop,
    int index,
  ) {
    double scoreVal = double.tryParse(score) ?? 0.0;
    Color scoreColor = scoreVal >= 4.5
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
    Color scoreBg = scoreColor.withValues(alpha: 0.1);

    bool isSelected = _selectedLogIndex == index;

    Color iconBg = isSelected ? OtrTheme.primaryBlue : const Color(0xFFF1F5F9);
    Color iconColor = isSelected ? Colors.white : OtrTheme.darkNavy;

    Color eyeBg = isSelected ? OtrTheme.primaryBlue : Colors.white;
    Color eyeBorder = isSelected ? OtrTheme.primaryBlue : Colors.grey.shade200;
    Color eyeIcon = isSelected ? Colors.white : Colors.blueGrey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLogIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: !isDesktop
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.business_center_rounded,
                          color: iconColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: OtrTheme.darkNavy,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scoreBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          score,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: scoreColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: OtrTheme.darkNavy,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: eyeBg,
                          border: Border.all(color: eyeBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.remove_red_eye_outlined,
                          size: 18,
                          color: eyeIcon,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.business_center_rounded,
                            color: iconColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: OtrTheme.darkNavy,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scoreBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            score,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: scoreColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: OtrTheme.darkNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: eyeBg,
                          border: Border.all(color: eyeBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.remove_red_eye_outlined,
                          size: 18,
                          color: eyeIcon,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.school,
                    color: OtrTheme.primaryBlue,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'JadeEdu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: OtrTheme.darkNavy,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          _buildSidebarItem(Icons.dashboard_rounded, 'Dashboard', false),
          _buildSidebarItem(Icons.campaign_rounded, 'Open EOIs', false),
          _buildSidebarItem(Icons.description_rounded, 'My Bids', false),
          _buildSidebarItem(Icons.work_rounded, 'Work Orders', false),
          _buildSidebarItem(
            Icons.currency_rupee_rounded,
            'Invoices & Payments',
            false,
          ),
          _buildSidebarItem(Icons.analytics_rounded, 'Performance', true),
          _buildSidebarItem(Icons.folder_shared_rounded, 'Documents', false),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? OtrTheme.darkNavy : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: OtrTheme.darkNavy.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey.shade600,
            size: 22,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              color: isActive ? Colors.white : Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'JadeQuest',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: OtrTheme.darkNavy,
                    ),
                  ),
                  Text(
                    'yeah@jadequest.com',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(
                  Icons.person_outline,
                  size: 22,
                  color: OtrTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
