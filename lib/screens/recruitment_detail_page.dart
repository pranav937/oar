import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../models/advertisement_model.dart';

class RecruitmentDetailPage extends StatelessWidget {
  const RecruitmentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Receiving recruitment data via arguments
    final data = ModalRoute.of(context)!.settings.arguments as Advertisement;
    final isClosed = data.status.toUpperCase() == 'CLOSED';

    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Recruitment Info',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Floating Header Card
            _buildMainHeader(data),
            const SizedBox(height: 24),

            // Vacancy Breakdown Section
            _buildVacancyBreakdown(data.breakdowns),
            const SizedBox(height: 24),

            // Fee DetailsSection
            _buildFeeSection(data.fees),
            const SizedBox(height: 32),

            // Summary Grid
            _buildSummaryGrid(data),
            const SizedBox(height: 32),

            // English Description
            _buildDetailedSection(
              'Job Description (English)',
              data.contentEnglish,
              Icons.description_outlined,
            ),
            const SizedBox(height: 24),

            // Hindi Description
            _buildDetailedSection(
              'नौकरी का विवरण (Hindi)',
              data.contentHindi,
              Icons.translate_rounded,
            ),
            const SizedBox(height: 24),

            // Requirements Section
            _buildDetailedSection(
              'Key Requirements',
              'Education: ${data.qualifications}\n\nExperience: ${data.experience ?? "Freshers can apply"}',
              Icons.assignment_ind_outlined,
            ),
            const SizedBox(height: 24),

            // Additional Rules
            if (data.relaxationRules != null)
              _buildDetailedSection(
                'Relaxation Rules',
                data.relaxationRules!,
                Icons.gavel_rounded,
              ),

            const SizedBox(height: 40),

            // Apply Button
            ElevatedButton(
              onPressed: isClosed
                  ? null
                  : () {
                      Navigator.pushNamed(
                        context,
                        '/apply-now',
                        arguments: data,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isClosed ? Colors.grey : OtrTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: OtrTheme.primaryBlue.withOpacity(0.4),
              ),
              child: Text(
                isClosed ? 'APPLICATION CLOSED' : 'APPLY FOR THIS POST',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeader(Advertisement data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: OtrTheme.darkNavy.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: OtrTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              data.advNumber,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: OtrTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.postName.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.organization,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: OtrTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSimpleInfo(Icons.pin_outlined, 'Post Code', data.postCode),
              const Spacer(),
              _buildSimpleInfo(
                Icons.history_toggle_off_rounded,
                'Status',
                data.status,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(Advertisement data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OtrTheme.darkNavy,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  Icons.groups_rounded,
                  'VACANCIES',
                  '${data.vacancies}',
                  Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem(
                  Icons.payments_rounded,
                  'PAY SCALE',
                  data.payScale,
                  Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  Icons.psychology_rounded,
                  'EXAM TYPE',
                  data.examType,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem(
                  Icons.how_to_reg_rounded,
                  'AGE LIMIT',
                  '${data.minAge}-${data.maxAge}',
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color.withOpacity(0.5), size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(0.4),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSimpleInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: OtrTheme.darkNavy,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedSection(String title, String content, IconData icon) {
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
          Row(
            children: [
              Icon(icon, color: OtrTheme.primaryBlue, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: OtrTheme.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVacancyBreakdown(List<VacancyBreakdown> breakdowns) {
    if (breakdowns.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: OtrTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Vacancy Distribution',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: OtrTheme.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...breakdowns.map((b) => _buildCategoryBar(b)).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(VacancyBreakdown b) {
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
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: OtrTheme.darkNavy,
                ),
              ),
              Text(
                '${b.allocatedPosts} Seats (${b.percentage}%)',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: OtrTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: b.percentage / 100,
              backgroundColor: Colors.grey.shade100,
              color: OtrTheme.primaryBlue,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeSection(List<ApplicationFee> fees) {
    if (fees.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_rounded, color: OtrTheme.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(
                'Application Fees',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: OtrTheme.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...fees
              .map(
                (fee) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fee.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      if (fee.isExempted)
                        const Text(
                          'EXEMPTED',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        )
                      else
                        Text(
                          '₹${fee.amount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: OtrTheme.darkNavy,
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
