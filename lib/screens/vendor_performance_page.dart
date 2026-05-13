import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VendorPerformancePage extends StatefulWidget {
  const VendorPerformancePage({super.key});

  @override
  State<VendorPerformancePage> createState() => _VendorPerformancePageState();
}

class _VendorPerformancePageState extends State<VendorPerformancePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _performanceHistory = [];
  String _error = '';

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
          _performanceHistory = result['data'] ?? [];
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load performance data';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Performance Insights',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: OtrTheme.darkNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCube(color: OtrTheme.primaryBlue, size: 40),
            )
          : _error.isNotEmpty
              ? _buildErrorPlaceholder()
              : RefreshIndicator(
                  onRefresh: _fetchPerformance,
                  color: OtrTheme.primaryBlue,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryHeader(),
                        const SizedBox(height: 32),
                        const Text(
                          'HISTORY & TRACK RECORD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _performanceHistory.isEmpty
                            ? _buildEmptyState()
                            : _buildPerformanceList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: OtrTheme.primaryBlue,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: OtrTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.stars_rounded,
            color: Colors.amberAccent,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            '4.8 / 5.0',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Text(
            'Overall Performance Rating',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('PROMPTNESS', 'High'),
              _buildStatItem('QUALITY', 'Top-Tier'),
              _buildStatItem('BIDS', '9+'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Colors.white54,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _performanceHistory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _performanceHistory[index];
        return _buildPerformanceCard(item);
      },
    );
  }

  Widget _buildPerformanceCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? 'Completed Project',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: OtrTheme.darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['date'] ?? 'Jan 2026',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'RATING',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${data['rating'] ?? 5.0}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: OtrTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.insights_rounded,
            size: 100,
            color: Colors.blueGrey.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Insights Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Participate in EOIs and execute projects to\nbuild your performance history.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 24),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: OtrTheme.darkNavy,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchPerformance,
              style: ElevatedButton.styleFrom(
                backgroundColor: OtrTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
