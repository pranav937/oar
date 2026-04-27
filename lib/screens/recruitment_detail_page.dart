import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../models/advertisement_model.dart';

class RecruitmentDetailPage extends StatelessWidget {
  const RecruitmentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Advertisement;
    final isClosed = data.status.toUpperCase() == 'CLOSED';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(data, context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildQuickStats(data),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    'Vacancy Distribution',
                    Icons.analytics_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildVacancyBreakdown(data.breakdowns),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    'Fee Structure',
                    Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildFeeSection(data.fees),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    'Detailed Description',
                    Icons.description_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard('English', data.contentEnglish),
                  const SizedBox(height: 16),
                  _buildInfoCard('Hindi (हिंदी)', data.contentHindi),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    'Qualifications',
                    Icons.workspace_premium_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard('Requirements', data.qualifications),
                  const SizedBox(height: 40),
                  _buildApplyButton(isClosed, context, data),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Advertisement data, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260.0,
      floating: false,
      pinned: true,
      backgroundColor: OtrTheme.darkNavy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [OtrTheme.darkNavy, Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: 40,
                child: Icon(
                  Icons.business_center_rounded,
                  size: 180,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        data.advNumber,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.postName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white60,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data.organization,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(Advertisement data) {
    return Row(
      children: [
        _buildStatBox(
          'Vacancies',
          data.vacancies.toString(),
          Icons.groups_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          'Pay Scale',
          data.payScale,
          Icons.currency_rupee_rounded,
          Colors.green,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          'Age Limit',
          '${data.minAge}-${data.maxAge}',
          Icons.cake_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: OtrTheme.darkNavy,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: OtrTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: OtrTheme.primaryBlue, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: OtrTheme.darkNavy,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVacancyBreakdown(List<VacancyBreakdown> breakdowns) {
    final colors = [
      OtrTheme.primaryBlue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.redAccent,
      Colors.pink,
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OtrTheme.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: breakdowns.asMap().entries.map((entry) {
          final i = entry.key;
          final b = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: OtrTheme.darkNavy,
                      ),
                    ),
                    Text(
                      '${b.allocatedPosts} Seats',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: colors[i % colors.length],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: b.percentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    color: colors[i % colors.length],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeeSection(List<ApplicationFee> fees) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: fees
            .map(
              (fee) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fee.category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      fee.isExempted ? 'FREE' : '₹${fee.amount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: fee.isExempted
                            ? Colors.green
                            : OtrTheme.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: OtrTheme.primaryBlue,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(
    bool isClosed,
    BuildContext context,
    Advertisement data,
  ) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: OtrTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isClosed
            ? null
            : () => Navigator.pushNamed(context, '/apply-now', arguments: data),
        style: ElevatedButton.styleFrom(
          backgroundColor: isClosed ? Colors.grey : OtrTheme.primaryBlue,
          minimumSize: const Size.fromHeight(65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          isClosed ? 'APPLICATION CLOSED' : 'APPLY FOR THIS POSITION',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
