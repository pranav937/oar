import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import '../models/eoi_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VendorOpenEoisPage extends StatefulWidget {
  const VendorOpenEoisPage({super.key});

  @override
  State<VendorOpenEoisPage> createState() => _VendorOpenEoisPageState();
}

class _VendorOpenEoisPageState extends State<VendorOpenEoisPage> {
  final ApiService _apiService = ApiService();
  List<EoiModel> _eois = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchEOIs();
  }

  Future<void> _fetchEOIs() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await _apiService.getVendorEOIs(status: 'PUBLISHED');
      if (result['success'] == true) {
        setState(() {
          _eois = (result['data'] as List)
              .map((item) => EoiModel.fromJson(item))
              .toList();
        });
      } else {
        setState(() => _error = result['message'] ?? 'Failed to load EOIs');
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
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Open EOIs',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: OtrTheme.surface,
        foregroundColor: OtrTheme.darkNavy,
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
              : _eois.isEmpty
                  ? const Center(child: Text('No open EOIs found.'))
                  : RefreshIndicator(
                      onRefresh: _fetchEOIs,
                      color: OtrTheme.primaryBlue,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _eois.length,
                        itemBuilder: (context, index) {
                          return _buildEoiCard(_eois[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildEoiCard(EoiModel eoi) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eoi.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: OtrTheme.darkNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${eoi.uuid.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge('OPEN', OtrTheme.success),
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
                    'CATEGORY',
                    eoi.vendorCategory,
                    Icons.business_center_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoItem(
                    'DEADLINE',
                    _formatDate(eoi.lastDateSubmission),
                    Icons.calendar_today_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/vendor-submit-proposal',
                  arguments: eoi,
                );
                if (result == true) {
                  _fetchEOIs();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OtrTheme.primaryBlue,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('SUBMIT PROPOSAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
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
        '✓ $status',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: OtrTheme.error),
          const SizedBox(height: 16),
          Text(_error),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchEOIs, child: const Text('Retry')),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
