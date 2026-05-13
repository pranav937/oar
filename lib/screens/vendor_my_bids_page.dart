import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VendorMyBidsPage extends StatefulWidget {
  const VendorMyBidsPage({super.key});

  @override
  State<VendorMyBidsPage> createState() => _VendorMyBidsPageState();
}

class _VendorMyBidsPageState extends State<VendorMyBidsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _bids = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchBids();
  }

  Future<void> _fetchBids() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await _apiService.getVendorBids();
      if (result['success'] == true) {
        setState(() {
          _bids = result['data'] ?? [];
        });
      } else {
        setState(() => _error = result['message'] ?? 'Failed to load bids');
      }
    } catch (e) {
      setState(() => _error = 'An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Bids',
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
      body: _isLoading
          ? const Center(child: SpinKitPulse(color: OtrTheme.primaryBlue))
          : _error.isNotEmpty
              ? _buildErrorPlaceholder()
              : _bids.isEmpty
                  ? const Center(child: Text('No bids found.'))
                  : RefreshIndicator(
                      onRefresh: _fetchBids,
                      color: OtrTheme.primaryBlue,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _bids.length,
                        itemBuilder: (context, index) {
                          return _buildBidCard(_bids[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildBidCard(dynamic bid) {
    final String uuid = bid['uuid'] ?? '';
    final String shortUuid = uuid.length > 8 ? uuid.substring(0, 8).toUpperCase() : uuid;
    final String status = bid['evaluationStatus'] ?? 'PENDING';
    
    Color statusColor = OtrTheme.warning;
    if (status.toUpperCase() == 'ACCEPTED') statusColor = OtrTheme.success;
    if (status.toUpperCase() == 'REJECTED') statusColor = OtrTheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: OtrTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Project Submission #$shortUuid',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: OtrTheme.darkNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                _buildStatusBadge(status, statusColor),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, thickness: 1, color: OtrTheme.dividerColor),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'FINANCIAL QUOTE',
                    '₹${bid['financialQuote'] ?? '0'}',
                    Icons.currency_rupee_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoItem(
                    'SUBMITTED ON',
                    _formatDate(bid['submittedAt']),
                    Icons.event_note_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OtrTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('AUDIT TIMELINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: OtrTheme.primaryBlue.withValues(alpha: 0.2), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('VIEW PROPOSAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: OtrTheme.primaryBlue)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: OtrTheme.darkNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy)),
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchBids, child: const Text('Retry')),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString());
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr.toString();
    }
  }
}
