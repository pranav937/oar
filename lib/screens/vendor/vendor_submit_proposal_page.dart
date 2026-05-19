import 'package:flutter/material.dart';
import '../../theme/otr_theme.dart';
import '../../services/api_service.dart';
import '../../models/vendor/eoi_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VendorSubmitProposalPage extends StatefulWidget {
  final EoiModel eoi;
  const VendorSubmitProposalPage({super.key, required this.eoi});

  @override
  State<VendorSubmitProposalPage> createState() => _VendorSubmitProposalPageState();
}

class _VendorSubmitProposalPageState extends State<VendorSubmitProposalPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _quoteController = TextEditingController();
  final _summaryController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final bidData = {
        "eoiUuid": widget.eoi.uuid,
        "financialQuote": double.tryParse(_quoteController.text) ?? 0,
        "proposalSummary": _summaryController.text,
      };

      final result = await _apiService.submitBid(bidData);

      if (result['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal submitted successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Submission failed'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: OtrTheme.darkNavy, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Submit Proposal',
                style: TextStyle(color: OtrTheme.darkNavy, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              centerTitle: true,
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 60 : 16,
                      vertical: isDesktop ? 32 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroHeader(isDesktop),
                        const SizedBox(height: 24),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 7, child: _buildMainForm(isDesktop)),
                              const SizedBox(width: 32),
                              Expanded(flex: 3, child: _buildSidebar(isDesktop)),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildMainForm(isDesktop),
                              const SizedBox(height: 24),
                              _buildSidebar(isDesktop),
                            ],
                          ),
                        const SizedBox(height: 40),
                        Center(
                          child: _buildSubmitButton(),
                        ),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildTopBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: OtrTheme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          const Text(
            'JadeEdu',
            style: TextStyle(color: OtrTheme.darkNavy, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1),
          ),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: OtrTheme.primaryBlue)),
          const SizedBox(width: 16),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('JadeQuest', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: OtrTheme.darkNavy)),
              Text('yeah@jadequest.com', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(Icons.person_outline, size: 22, color: OtrTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.logout_rounded, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: OtrTheme.dividerColor, width: 1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.school, color: OtrTheme.primaryBlue, size: 40)),
                const SizedBox(width: 12),
                const Text('JadeEdu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: OtrTheme.darkNavy)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSidebarItem(Icons.dashboard_outlined, 'Dashboard', false),
          _buildSidebarItem(Icons.campaign_outlined, 'Open EOIs', true),
          _buildSidebarItem(Icons.description_outlined, 'My Bids', false),
          _buildSidebarItem(Icons.assignment_outlined, 'Work Orders', false),
          _buildSidebarItem(Icons.receipt_long_outlined, 'Invoices & Payments', false),
          _buildSidebarItem(Icons.trending_up_rounded, 'Performance', false),
          _buildSidebarItem(Icons.folder_open_outlined, 'Documents', false),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? OtrTheme.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? OtrTheme.primaryBlue : Colors.grey.shade600, size: 22),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              color: isActive ? OtrTheme.primaryBlue : Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: isDesktop ? 48 : 32,
      ),
      decoration: BoxDecoration(
        color: OtrTheme.darkNavy,
        borderRadius: BorderRadius.circular(isDesktop ? 40 : 24),
        boxShadow: [
          BoxShadow(
            color: OtrTheme.darkNavy.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadge(widget.eoi.vendorCategory.toUpperCase(), const Color(0xFF334155)),
              const SizedBox(width: 12),
              _buildBadge('ACTIVE EOI', const Color(0xFF065F46)),
            ],
          ),
          SizedBox(height: isDesktop ? 24 : 16),
          Text(
            widget.eoi.title,
            style: TextStyle(
              fontSize: isDesktop ? 48 : 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.eoi.vendorCategory.toUpperCase()} • ACTIVE EOI',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildMainForm(bool isDesktop) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildFormCard(
            isDesktop: isDesktop,
            icon: Icons.currency_rupee_rounded,
            title: 'FINANCIAL QUOTE (TOTAL INR)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuoteInput(isDesktop),
                const SizedBox(height: 16),
                Text(
                  'ENTER THE TOTAL ALL-INCLUSIVE COST FOR THE ENTIRE SCOPE OF WORK.',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isDesktop ? 32 : 20),
          _buildFormCard(
            isDesktop: isDesktop,
            icon: Icons.description_outlined,
            title: 'PROPOSAL SUMMARY',
            child: _buildSummaryInput(isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({required bool isDesktop, required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 40 : 20),
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
            children: [
              Icon(icon, size: 18, color: OtrTheme.primaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: isDesktop ? 24 : 16),
          child,
        ],
      ),
    );
  }

  Widget _buildQuoteInput(bool isDesktop) {
    return TextFormField(
      controller: _quoteController,
      keyboardType: TextInputType.number,
      style: TextStyle(
        fontSize: isDesktop ? 40 : 32,
        fontWeight: FontWeight.w900,
        color: OtrTheme.darkNavy,
        height: 1.2,
      ),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(color: Colors.grey.shade300),
        suffixText: 'INR',
        suffixStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 16,
          vertical: isDesktop ? 20 : 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
          borderSide: const BorderSide(color: OtrTheme.primaryBlue, width: 1.5),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Field required' : null,
    );
  }

  Widget _buildSummaryInput(bool isDesktop) {
    return TextFormField(
      controller: _summaryController,
      maxLines: isDesktop ? 10 : 6,
      style: TextStyle(
        fontSize: isDesktop ? 16 : 14,
        color: OtrTheme.darkNavy,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Outline your methodology, timeline, resource allocation, and technical strategy...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.all(isDesktop ? 24 : 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
          borderSide: const BorderSide(color: OtrTheme.primaryBlue, width: 1.5),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Field required' : null,
    );
  }

  Widget _buildSidebar(bool isDesktop) {
    return Column(
      children: [
        _buildSidebarCard(
          isDesktop: isDesktop,
          title: 'ELIGIBILITY CRITERIA',
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
            ),
            child: Text(
              '"${widget.eoi.eligibilityCriteria}"',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 13,
                fontWeight: FontWeight.w700,
                color: OtrTheme.darkNavy,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        _buildSidebarCard(
          isDesktop: isDesktop,
          title: 'ENGAGEMENT OVERVIEW',
          child: Column(
            children: [
              _buildOverviewItem(Icons.description_outlined, 'TYPE', widget.eoi.vendorCategory, const Color(0xFFE0F2FE)),
              SizedBox(height: isDesktop ? 16 : 12),
              _buildOverviewItem(Icons.currency_rupee_rounded, 'BUDGET', 'Competitive Bidding', const Color(0xFFF0FDF4)),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        Container(
          padding: EdgeInsets.all(isDesktop ? 32 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFFCFEAF7),
            borderRadius: BorderRadius.circular(isDesktop ? 32 : 20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SUBMISSION NOTE',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: OtrTheme.darkNavy),
              ),
              const SizedBox(height: 8),
              Text(
                'Once submitted, your proposal will enter technical evaluation. You cannot edit after submission.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: OtrTheme.darkNavy.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarCard({required bool isDesktop, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 32 : 20),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          child,
        ],
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String label, String value, Color iconBg) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: OtrTheme.primaryBlue),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _isSubmitting ? null : _submitProposal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            color: OtrTheme.darkNavy,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: OtrTheme.darkNavy.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSubmitting)
                const SpinKitThreeBounce(color: Colors.white, size: 20)
              else ...[
                const Text(
                  'SUBMIT PROPOSAL',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

