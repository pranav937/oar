import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import '../models/eoi_model.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Submit Proposal',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Financial Quote (₹)'),
                    const SizedBox(height: 12),
                    _buildQuoteField(),
                    const SizedBox(height: 8),
                    const Text(
                      'GST and other taxes will be calculated as per applicable laws.',
                      style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionLabel('Tell us more about your proposal summary'),
                    const SizedBox(height: 12),
                    _buildSummaryField(),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitProposal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OtrTheme.primaryBlue,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                          : const Text('SUBMIT PROPOSAL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: OtrTheme.primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.intenseShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.eoi.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✓ OPEN',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${widget.eoi.uuid.toUpperCase()}',
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'Submission deadline: ${_formatDate(widget.eoi.lastDateSubmission)}',
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
    );
  }

  Widget _buildQuoteField() {
    return TextFormField(
      controller: _quoteController,
      keyboardType: TextInputType.number,
      validator: (v) => v!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('₹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: OtrTheme.dividerColor, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: OtrTheme.primaryBlue, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
    );
  }

  Widget _buildSummaryField() {
    return TextFormField(
      controller: _summaryController,
      maxLines: 6,
      validator: (v) => v!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        hintText: 'Enter your proposal details here...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: OtrTheme.dividerColor, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: OtrTheme.primaryBlue, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
