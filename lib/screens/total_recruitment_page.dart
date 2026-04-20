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
          'Available Jobs',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _recruitments.length,
                          itemBuilder: (context, index) {
                            return _buildRecruitmentCard(context, _recruitments[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search recruitments...',
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.black38),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(_error, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          TextButton(onPressed: _fetchRecruitments, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildRecruitmentCard(BuildContext context, Advertisement data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: OtrTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.status,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: OtrTheme.primaryBlue),
                ),
              ),
              const Icon(Icons.bookmark_border_rounded, color: Colors.black26),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.postName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
          ),
          const SizedBox(height: 4),
          Text(
            data.organization,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OtrTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.black38),
              const SizedBox(width: 4),
              Text('Ends: ${data.lastDateToApply}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(width: 16),
              const Icon(Icons.account_balance_wallet_outlined, size: 14, color: Colors.black38),
              const SizedBox(width: 4),
              Text(data.payScale, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/recruitment-detail', arguments: data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: OtrTheme.darkNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Info', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/apply-now', arguments: data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OtrTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
