import 'package:flutter/material.dart';
import '../../theme/otr_theme.dart';
import '../../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VendorMyBidsPage extends StatefulWidget {
  const VendorMyBidsPage({super.key});

  @override
  State<VendorMyBidsPage> createState() => _VendorMyBidsPageState();
}

class _VendorMyBidsPageState extends State<VendorMyBidsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _bids = [];
  List<dynamic> _filteredBids = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedBidUuids = {};

  @override
  void initState() {
    super.initState();
    _fetchBids();
    _searchController.addListener(_filterBids);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _filteredBids = _bids;
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

  void _filterBids() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBids = _bids.where((bid) {
        final eoi = bid['eoi'] ?? {};
        final title = (eoi['title'] ?? '').toString().toLowerCase();
        final eoiNumber = (eoi['eoiNumber'] ?? '').toString().toLowerCase();
        final uuid = (bid['uuid'] ?? '').toString().toLowerCase();
        return title.contains(query) ||
            eoiNumber.contains(query) ||
            uuid.contains(query);
      }).toList();
    });
  }

  void _toggleSelectAll(bool? selected) {
    setState(() {
      if (selected == true) {
        for (var bid in _filteredBids) {
          _selectedBidUuids.add(bid['uuid'].toString());
        }
      } else {
        _selectedBidUuids.clear();
      }
    });
  }

  void _toggleSelectBid(String uuid) {
    setState(() {
      if (_selectedBidUuids.contains(uuid)) {
        _selectedBidUuids.remove(uuid);
      } else {
        _selectedBidUuids.add(uuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Bids',
          style: TextStyle(
            color: OtrTheme.darkNavy,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: OtrTheme.darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: SpinKitPulse(color: OtrTheme.primaryBlue))
          : RefreshIndicator(
              onRefresh: _fetchBids,
              color: OtrTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proposal Scrutiny',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: OtrTheme.darkNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _filteredBids.isNotEmpty &&
                                    _selectedBidUuids.length ==
                                        _filteredBids.length,
                                onChanged: _toggleSelectAll,
                                activeColor: OtrTheme.primaryBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Select All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: OtrTheme.darkNavy,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Total: ${_filteredBids.length} Items',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: OtrTheme.darkNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_error.isNotEmpty)
                      _buildErrorPlaceholder()
                    else if (_filteredBids.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(
                          child: Text('No bids found.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredBids.length,
                        itemBuilder: (context, index) {
                          return _buildBidCard(_filteredBids[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by ID or Title...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildBidCard(dynamic bid) {
    // Correct mapping based on the provided API response structure
    final eoi = bid['eoi'] ?? {};
    final String title = eoi['title'] ?? 'N/A';
    final String eoiNumber = eoi['eoiNumber'] ?? 'N/A';
    
    // Formatting currency for financial quote
    final dynamic rawQuote = bid['financialQuote'];
    String bidValue = '₹ 0';
    if (rawQuote != null) {
      bidValue = '₹ ${rawQuote.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
    
    final String submissionDate = _formatDate(bid['submittedAt']);
    final String status = (bid['evaluationStatus'] ?? 'PENDING').toUpperCase();

    Color statusColor = const Color(0xFFF59E0B); // Orange for Pending
    if (status == 'SELECTED' || status == 'ACCEPTED') {
      statusColor = const Color(0xFF10B981); // Green for Selected
    } else if (status == 'REJECTED') {
      statusColor = const Color(0xFFEF4444); // Red for Rejected
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _selectedBidUuids.contains(bid['uuid'].toString()),
                    onChanged: (val) => _toggleSelectBid(bid['uuid'].toString()),
                    activeColor: OtrTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: OtrTheme.darkNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRowItem('EOI Number', eoiNumber, isBold: false),
            const SizedBox(height: 12),
            _buildRowItem('Bid Value', bidValue, isBold: true),
            const SizedBox(height: 12),
            _buildRowItem('Submission Date', submissionDate, isBold: false),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: OtrTheme.darkNavy,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String label, String value, {required bool isBold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? OtrTheme.darkNavy : Colors.black87,
          ),
        ),
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
    if (dateStr == '14/05/2026') return dateStr; // Placeholder handling
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr.toString();
    }
  }
}
