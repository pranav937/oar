import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import '../models/advertisement_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TotalRecruitmentPage extends StatefulWidget {
  const TotalRecruitmentPage({super.key});

  @override
  State<TotalRecruitmentPage> createState() => _TotalRecruitmentPageState();
}

class _TotalRecruitmentPageState extends State<TotalRecruitmentPage> {
  final ApiService _apiService = ApiService();
  List<Advertisement> _recruitments = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchRecruitments();
  }

  Future<void> _fetchRecruitments() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await _apiService.getJobs();
      if (result['success'] == true) {
        setState(() {
          _recruitments = (result['data'] as List)
              .map((item) => Advertisement.fromJson(item))
              .toList();
        });
      } else {
        setState(() => _error = result['message'] ?? 'Failed to load jobs');
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
          'Recruitment Openings',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: SpinKitPulse(color: OtrTheme.primaryBlue))
                : _error.isNotEmpty
                    ? _buildErrorPlaceholder()
                    : RefreshIndicator(
                        onRefresh: _fetchRecruitments,
                        color: OtrTheme.primaryBlue,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _recruitments.length,
                          itemBuilder: (context, index) {
                            return _buildRecruitmentCard(
                              context,
                              _recruitments[index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: OtrTheme.softShadow,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by post or department...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: OtrTheme.primaryBlue),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: OtrTheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, size: 40, color: OtrTheme.error),
          ),
          const SizedBox(height: 16),
          Text(_error, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchRecruitments,
            style: ElevatedButton.styleFrom(
              backgroundColor: OtrTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitmentCard(BuildContext context, Advertisement data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: OtrTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Status
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: OtrTheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.advNumber,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildStatusBadge(data.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.postName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: OtrTheme.darkNavy,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.account_balance_rounded, size: 14, color: OtrTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.organization,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: OtrTheme.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                ),

                // Info Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(Icons.group_rounded, 'Vacancies', '${data.vacancies}'),
                    _buildInfoItem(Icons.currency_rupee_rounded, 'Salary', data.payScale),
                    _buildInfoItem(Icons.calendar_today_rounded, 'Deadline', _formatDate(data.lastDateToApply)),
                  ],
                ),
                
                const SizedBox(height: 28),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/recruitment-detail', arguments: data),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'DETAILS',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: OtrTheme.darkNavy,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: OtrTheme.primaryBlue.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/apply-now', arguments: data),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OtrTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'APPLY NOW',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isOpen = status.toUpperCase() == 'OPEN' || status.toUpperCase() == 'PUBLISHED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? OtrTheme.success.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? OtrTheme.success : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'OPEN' : status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isOpen ? OtrTheme.success : Colors.orange,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 14, color: OtrTheme.primaryBlue.withValues(alpha: 0.5)),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: OtrTheme.darkNavy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return dateStr;
    }
  }
}

