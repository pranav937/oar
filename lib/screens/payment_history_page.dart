import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String _error = '';

  /// Merged & normalized list — mirrors React's `payments` state
  List<Map<String, dynamic>> _payments = [];

  // ── Computed stats ──────────────────────────────────────────────────────────
  double _parseAmount(Map<String, dynamic> p) {
    final val = p['amount'] ?? p['amountPaid'] ?? p['feeAmount'] ?? 0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  double get _totalSettlement => _payments
      .where((p) => (p['status'] ?? '').toString().toUpperCase() == 'SUCCESS')
      .fold(0.0, (sum, p) => sum + _parseAmount(p));

  double get _totalEscrow => _payments
      .where((p) => (p['status'] ?? '').toString().toUpperCase() == 'PENDING')
      .fold(0.0, (sum, p) => sum + _parseAmount(p));

  int get _successVolume => _payments
      .where((p) => (p['status'] ?? '').toString().toUpperCase() == 'SUCCESS')
      .length;

  double get _failureRate {
    if (_payments.isEmpty) return 0.0;
    final failed = _payments
        .where((p) => (p['status'] ?? '').toString().toUpperCase() == 'FAILED')
        .length;
    return (failed / _payments.length) * 100;
  }

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  // ── Fetch + Merge (mirrors React loadPayments) ──────────────────────────────
  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final results = await Future.wait([
        _apiService.getPaymentHistory(page: 1, pageSize: 20),
        _apiService.getAppliedRecruitments(page: 1, pageSize: 20),
      ]);

      final paymentRes = results[0];
      final appRes = results[1];

      final List<Map<String, dynamic>> history = _extractList(paymentRes, [
        'transactions',
        'payments',
        'data',
        'items',
      ]).whereType<Map<String, dynamic>>().toList();

      final List<Map<String, dynamic>> applications = _extractList(appRes, [
        'applications',
        'data',
        'items',
      ]).whereType<Map<String, dynamic>>().toList();

      // Merge: add exempt entries for apps with no payment record
      final merged = List<Map<String, dynamic>>.from(history);

      for (final app in applications) {
        final appNum = app['applicationNumber']?.toString() ?? '';
        final appUuid = (app['uuid'] ?? app['applicationUuid'] ?? '')
            .toString();

        final exists = history.any(
          (p) =>
              p['applicationNumber']?.toString() == appNum ||
              (p['applicationUuid'] ?? p['uuid'])?.toString() == appUuid,
        );

        if (!exists) {
          merged.add({
            'transactionId': 'APP-$appNum',
            'applicationNumber': appNum,
            'applicationUuid': appUuid,
            'amount': app['amountPaid'] ?? 0,
            'status': 'SUCCESS',
            'isExempt': true,
            'postName': app['postName'] ?? app['postPreference1'] ?? 'N/A',
            'createdAt': app['submittedAt'] ?? app['createdAt'],
            'paymentMode': 'Exempt',
          });
        }
      }

      // Sort descending by date
      merged.sort((a, b) {
        try {
          final da =
              DateTime.tryParse(a['transactionDate']?.toString() ?? a['createdAt']?.toString() ?? '') ??
              DateTime(2000);
          final db =
              DateTime.tryParse(b['transactionDate']?.toString() ?? b['createdAt']?.toString() ?? '') ??
              DateTime(2000);
          return db.compareTo(da);
        } catch (_) {
          return 0;
        }
      });

      if (mounted) setState(() => _payments = merged);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load. Check connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> _extractList(Map<String, dynamic> res, List<String> keys) {
    final data = res['data'];
    if (data is List) return data;
    if (data is Map) {
      for (final k in keys) {
        if (data[k] is List) return data[k] as List;
      }
    }
    for (final k in keys) {
      if (res[k] is List) return res[k] as List;
    }
    return [];
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Payment History',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: OtrTheme.surface,
        surfaceTintColor: OtrTheme.surface,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchAll,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitWave(color: OtrTheme.primaryBlue, size: 30),
            )
          : _error.isNotEmpty
          ? _buildError()
          : RefreshIndicator(
              onRefresh: _fetchAll,
              color: OtrTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(),
                    const SizedBox(height: 14),
                    if (_payments.isEmpty)
                      _buildEmptyState()
                    else
                      ..._payments.map((p) => _buildPaymentCard(p)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Stats Row ───────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: OtrTheme.primaryBlue,
            label: 'TOTAL SETTLEMENT',
            value: '₹${_totalSettlement.toStringAsFixed(2)}',
            sub: 'TOTAL FEES PROCESSED',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: OtrTheme.success,
            label: 'SUCCESS VOLUME',
            value: _successVolume.toString(),
            sub: 'APPLICATIONS COMPLETED',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Text(
          'TRANSACTION REGISTRY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: OtrTheme.darkNavy,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: OtrTheme.lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_payments.length} records',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: OtrTheme.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  // ── Payment Card ────────────────────────────────────────────────────────────
  Widget _buildPaymentCard(Map<String, dynamic> p) {
    final statusRaw = (p['status'] ?? 'PENDING').toString().toUpperCase();
    final isSuccess = statusRaw == 'SUCCESS';
    final isFailed = statusRaw == 'FAILED' || statusRaw == 'FAILURE';
    final isExempt = p['isExempt'] == true;
    final amount = _parseAmount(p);
    final txnId = (p['transactionId'] ?? '').toString();
    final postName = (p['postName'] ?? 'N/A').toString();
    final payMode = (p['paymentMode'] ?? 'UPI').toString();
    final appNum = (p['applicationNumber'] ?? '').toString();

    // Date formatting
    String dateStr = 'N/A';
    try {
      final rawDate = p['transactionDate'] ?? p['createdAt'];
      if (rawDate != null) {
        dateStr = DateFormat(
          'dd MMM yyyy',
        ).format(DateTime.parse(rawDate.toString()));
      }
    } catch (_) {}

    Color statusColor = OtrTheme.warning;
    IconData statusIcon = Icons.pending_rounded;
    String statusLabel = statusRaw;

    if (isSuccess) {
      statusColor = OtrTheme.success;
      statusIcon = Icons.check_circle_rounded;
      statusLabel = isExempt ? 'EXEMPT' : 'SUCCESS';
    }
    if (isFailed) {
      statusColor = OtrTheme.error;
      statusIcon = Icons.cancel_rounded;
      statusLabel = 'FAILED';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: OtrTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: OtrTheme.cardShadow,
        border: isExempt
            ? Border.all(color: OtrTheme.success.withValues(alpha: 0.25))
            : null,
      ),
      child: Column(
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, size: 20, color: statusColor),
                ),
                const SizedBox(width: 14),
                // Post name + txn id + app number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: OtrTheme.darkNavy,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 11,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              txnId.isEmpty ? 'No TXN ID' : txnId,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (appNum.isNotEmpty)
                        Text(
                          'App# $appNum',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Amount + date + mode
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isExempt ? 'EXEMPT' : '₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isExempt ? OtrTheme.success : OtrTheme.darkNavy,
                      ),
                    ),
                    Text(
                      payMode,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: OtrTheme.mediumBlue,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: OtrTheme.dividerColor),

          // Bottom action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                // Copy TXN ID
                if (txnId.isNotEmpty)
                  _ActionButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy ID',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: txnId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied: $txnId'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(width: 10),
                // View Details
                _ActionButton(
                  icon: Icons.remove_red_eye_outlined,
                  label: 'View',
                  color: OtrTheme.primaryBlue,
                  bgColor: OtrTheme.lightBlue,
                  onTap: () => _openDetail(p),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(Map<String, dynamic> p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PaymentDetailPage(payment: p)),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: OtrTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: OtrTheme.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 14),
            Text(
              'Registry Empty',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No financial settlement records found.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: OtrTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchAll,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OtrTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OtrTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: valueColor ?? OtrTheme.darkNavy,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade400,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF64748B),
    this.bgColor = const Color(0xFFF1F5F9),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment Detail Page ──────────────────────────────────────────────────────

class _PaymentDetailPage extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentDetailPage({required this.payment});

  @override
  Widget build(BuildContext context) {
    final status = (payment['status'] ?? 'PENDING').toString().toUpperCase();
    final isSuccess = status == 'SUCCESS';
    final isFailed = status == 'FAILED' || status == 'FAILURE';
    final isExempt = payment['isExempt'] == true;

    Color statusColor = OtrTheme.warning;
    if (isSuccess) statusColor = OtrTheme.success;
    if (isFailed) statusColor = OtrTheme.error;

    String dateStr = 'N/A';
    try {
      final rawDate = payment['transactionDate'] ?? payment['createdAt'];
      if (rawDate != null) {
        dateStr = DateFormat(
          'dd MMM yyyy, hh:mm a',
        ).format(DateTime.parse(rawDate.toString()));
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Transaction Detail',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: OtrTheme.surface,
        surfaceTintColor: OtrTheme.surface,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess
                          ? Icons.check_circle_rounded
                          : isFailed
                          ? Icons.cancel_rounded
                          : Icons.pending_rounded,
                      size: 36,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isExempt
                        ? 'FEE EXEMPTED'
                        : isSuccess
                        ? 'TRANSACTION VERIFIED'
                        : isFailed
                        ? 'TRANSACTION FAILED'
                        : 'PENDING VERIFICATION',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: OtrTheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: OtrTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(
                    'TRANSACTION ID',
                    payment['transactionId']?.toString() ?? 'N/A',
                    Icons.tag_rounded,
                  ),
                  _divider(),
                  _detailRow(
                    'POST / POSITION',
                    payment['postName']?.toString() ?? 'N/A',
                    Icons.work_outline_rounded,
                  ),
                  _divider(),
                  _detailRow(
                    'EXEMPT',
                    isExempt ? 'Yes' : 'No',
                    isExempt ? Icons.verified_user_rounded : Icons.do_not_disturb_on_rounded,
                  ),
                  _divider(),
                  _detailRow(
                    'AMOUNT',
                    isExempt ? 'Exempt (₹0)' : '₹${(payment['amount'] ?? 0)}',
                    Icons.currency_rupee_rounded,
                  ),
                  _divider(),
                  _detailRow(
                    'PAYMENT MODE',
                    payment['paymentMode']?.toString() ?? 'UPI',
                    Icons.payment_rounded,
                  ),
                  _divider(),
                  _detailRow('DATE', dateStr, Icons.event_note_rounded),
                  if (payment['applicationNumber'] != null) ...[
                    _divider(),
                    _detailRow(
                      'APPLICATION NO.',
                      payment['applicationNumber'].toString(),
                      Icons.fingerprint_rounded,
                    ),
                  ],
                  if (payment['responseMessage'] != null) ...[
                    _divider(),
                    _detailRow(
                      'GATEWAY RESPONSE',
                      payment['responseMessage'].toString(),
                      Icons.info_outline_rounded,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Divider(height: 1, color: OtrTheme.dividerColor),
  );

  Widget _detailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: OtrTheme.lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: OtrTheme.primaryBlue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: OtrTheme.darkNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
