import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VendorWorkOrdersPage extends StatefulWidget {
  const VendorWorkOrdersPage({super.key});

  @override
  State<VendorWorkOrdersPage> createState() => _VendorWorkOrdersPageState();
}

class _VendorWorkOrdersPageState extends State<VendorWorkOrdersPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _workOrders = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchWorkOrders();
  }

  Future<void> _fetchWorkOrders() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await _apiService.getVendorWorkOrders();
      if (result['success'] == true) {
        setState(() {
          _workOrders = result['data'] ?? [];
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load work orders';
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
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: OtrTheme.darkNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCube(color: OtrTheme.primaryBlue, size: 40),
            )
          : RefreshIndicator(
              onRefresh: _fetchWorkOrders,
              color: OtrTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        'Operational Work Orders',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: OtrTheme.darkNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Review and execute assigned tasks and deliverables',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _workOrders.isEmpty
                          ? _buildPortalEmptyState()
                          : _buildWorkOrdersList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPortalEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 64,
              color: Colors.blueGrey.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No work orders assigned to you yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrdersList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _workOrders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _workOrders[index];
        return _buildWorkOrderCard(item);
      },
    );
  }

  Widget _buildWorkOrderCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: OtrTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data['orderId'] ?? 'WO-001',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: OtrTheme.primaryBlue,
                  ),
                ),
              ),
              _buildStatusBadge(data['status'] ?? 'ACTIVE'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            data['title'] ?? 'Strategic Project Task',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: OtrTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_note_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Issued: ${data['issueDate'] ?? '13 May 2026'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.green,
        ),
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
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: OtrTheme.darkNavy),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchWorkOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
