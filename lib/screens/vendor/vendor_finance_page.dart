import 'package:flutter/material.dart';
import '../../theme/otr_theme.dart';
import '../../services/api_service.dart';
import '../../models/vendor/vendor_finance_models.dart';
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
          _invoices = (results[0]['data'] as List)
              .map((i) => VendorInvoiceModel.fromJson(i))
              .toList();
          _payments = (results[1]['data'] as List)
              .map((p) => VendorPaymentModel.fromJson(p))
              .toList();
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
  int get _pendingInvoices =>
      _invoices.where((i) => i.status == 'PENDING').length;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: OtrTheme.darkNavy,
        centerTitle: true,
        title: const Text(
          'Invoices & Payments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: OtrTheme.darkNavy,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitPulse(color: OtrTheme.primaryBlue, size: 50),
            )
          : RefreshIndicator(
              onRefresh: _fetchFinanceData,
              color: OtrTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildTopButton(isDesktop),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildMetricsGrid(isDesktop),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildHistorySection(isDesktop),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopButton(bool isDesktop) {
    final button = ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, '/vendor-raise-invoice')
          .then((_) => _fetchFinanceData()),
      icon: const Icon(Icons.add, size: 16, color: Colors.white),
      label: const Text('Raise new invoice',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: OtrTheme.darkNavy,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );

    if (isDesktop) {
      return Align(alignment: Alignment.centerRight, child: button);
    } else {
      return SizedBox(width: double.infinity, child: button);
    }
  }

  Widget _buildMetricsGrid(bool isDesktop) {
    final earnedCard = _buildMetricCard(
      label: 'TOTAL EARNED',
      value: _totalEarned,
      icon: Icons.currency_rupee_rounded,
      color: Colors.green,
      bg: const Color(0xFFDCFCE7),
      isCurrency: true,
      isDesktop: isDesktop,
    );

    final pendingCard = _buildMetricCard(
      label: 'PENDING INVOICES',
      value: _pendingInvoices,
      icon: Icons.access_time_rounded,
      color: Colors.orange,
      bg: const Color(0xFFFFF7ED),
      isCurrency: false,
      isDesktop: isDesktop,
    );

    return Row(
      children: [
        Expanded(child: earnedCard),
        SizedBox(width: isDesktop ? 24 : 12),
        Expanded(child: pendingCard),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required dynamic value,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isCurrency,
    required bool isDesktop,
  }) {
    final fmt = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹');
    final displayValue = isCurrency
        ? fmt.format(value)
        : value.toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.all(isDesktop ? 28 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 8),
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: isDesktop ? 24 : 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: isDesktop ? 11 : 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 24 : 16),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: isDesktop ? 32 : 22,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(bool isDesktop) {
    final invoicesCard = _buildHistoryCard(
      title: 'RECENT INVOICES',
      dotColor: OtrTheme.primaryBlue,
      data: _invoices,
      emptyMsg: 'No invoices raised yet.',
      isDesktop: isDesktop,
    );

    final disbursementsCard = _buildHistoryCard(
      title: 'DISBURSEMENT HISTORY',
      dotColor: Colors.green,
      data: _payments,
      emptyMsg: 'No disbursements recorded yet.',
      isDesktop: isDesktop,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: invoicesCard),
          const SizedBox(width: 24),
          Expanded(child: disbursementsCard),
        ],
      );
    } else {
      return Column(
        children: [
          invoicesCard,
          const SizedBox(height: 16),
          disbursementsCard,
        ],
      );
    }
  }

  Widget _buildHistoryCard({
    required String title,
    required Color dotColor,
    required List data,
    required String emptyMsg,
    required bool isDesktop,
  }) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 11,
                  fontWeight: FontWeight.w900,
                  color: OtrTheme.darkNavy,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 32 : 24),
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  emptyMsg,
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey.withValues(alpha: 0.1), height: isDesktop ? 32 : 24),
              itemBuilder: (context, index) {
                final item = data[index];
                if (item is VendorInvoiceModel) return _buildInvoiceItem(item, isDesktop);
                if (item is VendorPaymentModel) return _buildPaymentItem(item, isDesktop);
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(VendorInvoiceModel invoice, bool isDesktop) {
    Color statusColor;
    String statusText = invoice.status ?? 'UNKNOWN';
    if (statusText == 'PENDING') {
      statusColor = Colors.orange;
    } else if (statusText == 'PAID' || statusText == 'COMPLETED') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.blueGrey;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 12 : 10),
          decoration: BoxDecoration(
            color: OtrTheme.primaryBlue.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.description_rounded,
            color: OtrTheme.primaryBlue,
            size: isDesktop ? 20 : 18,
          ),
        ),
        SizedBox(width: isDesktop ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INV#${invoice.invoiceNumber} - Platform fee',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: isDesktop ? 13 : 12,
                  color: OtrTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(invoice.invoiceDate),
                style: TextStyle(
                  fontSize: isDesktop ? 11 : 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${invoice.totalAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isDesktop ? 14 : 13,
                color: OtrTheme.darkNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              statusText,
              style: TextStyle(
                fontSize: isDesktop ? 10 : 9,
                fontWeight: FontWeight.w900,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentItem(VendorPaymentModel payment, bool isDesktop) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 12 : 10),
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.green,
            size: isDesktop ? 20 : 18,
          ),
        ),
        SizedBox(width: isDesktop ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settlement Disbursed',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: isDesktop ? 13 : 12,
                  color: OtrTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(payment.paymentDate),
                style: TextStyle(
                  fontSize: isDesktop ? 11 : 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          '+₹${payment.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: isDesktop ? 14 : 13,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

