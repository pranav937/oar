import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import '../models/vendor_finance_models.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class VendorFinancePage extends StatefulWidget {
  const VendorFinancePage({super.key});

  @override
  State<VendorFinancePage> createState() => _VendorFinancePageState();
}

class _VendorFinancePageState extends State<VendorFinancePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<VendorInvoiceModel> _invoices = [];
  List<VendorPaymentModel> _payments = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchFinanceData();
  }

  Future<void> _fetchFinanceData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final results = await Future.wait([
        _apiService.getVendorInvoices(),
        _apiService.getVendorPayments(),
      ]);

      if (results[0]['success'] == true && results[1]['success'] == true) {
        setState(() {
          _invoices = (results[0]['data'] as List).map((i) => VendorInvoiceModel.fromJson(i)).toList();
          _payments = (results[1]['data'] as List).map((p) => VendorPaymentModel.fromJson(p)).toList();
        });
      } else {
        setState(() => _error = 'Failed to load financial data');
      }
    } catch (e) {
      setState(() => _error = 'An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _totalEarned => _payments.fold(0, (sum, p) => sum + p.amount);
  int get _pendingInvoices => _invoices.where((i) => i.status == 'PENDING').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: OtrTheme.darkNavy,
        centerTitle: true,
        title: const Text(
          'Finance & Payments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/vendor-raise-invoice').then((_) => _fetchFinanceData()),
            icon: const Icon(Icons.add_circle_outline_rounded, color: OtrTheme.primaryBlue, size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitPulse(color: OtrTheme.primaryBlue, size: 50),
            )
          : RefreshIndicator(
              onRefresh: _fetchFinanceData,
              color: OtrTheme.primaryBlue,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const Text(
                      'Finance & Payments',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage Invoices, track disbursements, and view earnings',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 40),
                    _buildMetricsGrid(),
                    const SizedBox(height: 32),
                    _buildHistorySection('RECENT INVOICES', 'No invoices raised yet.', Icons.receipt_long_outlined, _invoices),
                    const SizedBox(height: 20),
                    _buildHistorySection('DISBURSEMENT HISTORY', 'No disbursements recorded yet.', Icons.account_balance_wallet_outlined, _payments),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricsGrid() {
    final fmt = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹');
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard('TOTAL EARNED', fmt.format(_totalEarned), Icons.currency_rupee_rounded, Colors.green, const Color(0xFFDCFCE7)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMetricCard('PENDING', _pendingInvoices.toString(), Icons.access_time_rounded, Colors.orange, const Color(0xFFFEF9C3)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMetricCard('GROWTH SCORE', '8.4', Icons.trending_up_rounded, const Color(0xFF3B82F6), const Color(0xFFE0F2FE)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: color, size: 16)),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy)),
        ],
      ),
    );
  }

  Widget _buildHistorySection(String title, String emptyMsg, IconData icon, List data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.blueGrey.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (data.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(emptyMsg, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                if (item is VendorInvoiceModel) return _buildInvoiceItem(item);
                if (item is VendorPaymentModel) return _buildPaymentItem(item);
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(VendorInvoiceModel invoice) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: OtrTheme.darkNavy)),
                Text(DateFormat('dd MMM yyyy').format(invoice.invoiceDate), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Text('₹${invoice.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: OtrTheme.darkNavy)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(VendorPaymentModel payment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Settlement Disbursed', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: OtrTheme.darkNavy)),
                Text(DateFormat('dd MMM yyyy').format(payment.paymentDate), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Text('₹${payment.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.green)),
        ],
      ),
    );
  }
}

