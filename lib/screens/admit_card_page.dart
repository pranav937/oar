import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../utils/custom_toast.dart';
import '../utils/admit_card_generator.dart';
import '../theme/otr_theme.dart';
import 'admit_card_detail_page.dart';

class AdmitCardPage extends StatefulWidget {
  const AdmitCardPage({super.key});

  @override
  State<AdmitCardPage> createState() => _AdmitCardPageState();
}

class _AdmitCardPageState extends State<AdmitCardPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      setState(() => _isLoading = true);
      // API: Fetch applications list using the provided endpoint logic
      final response = await _apiService.getMyApplications(
        page: 1,
        pageSize: 20,
      );

      if (response['success'] == true) {
        final data = response['data'];
        List<dynamic> fetchedApps = [];
        if (data is Map && data.containsKey('applications')) {
          fetchedApps = data['applications'];
        } else if (data is List) {
          fetchedApps = data;
        } else if (data is Map && data.containsKey('items')) {
          fetchedApps = data['items'];
        }

        setState(() {
          // Filtering based on the provided JSON structure
          _applications = fetchedApps.where((app) {
            final status = (app['status'] ?? '').toString().toUpperCase();

            // Check nested statusTimeline for admitCardIssued
            bool isIssuedByTimeline = false;
            if (app['statusTimeline'] != null && app['statusTimeline'] is Map) {
              isIssuedByTimeline =
                  app['statusTimeline']['admitCardIssued'] == true;
            }

            // Also check for ADMIT_CARD_ISSUED status directly
            return status == 'ADMIT_CARD_ISSUED' || isIssuedByTimeline;
          }).toList();

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          CustomToast.showError(
            context,
            response['message'] ?? 'Failed to load applications',
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) CustomToast.showError(context, 'Error: $e');
    }
  }

  void _navigateToDetail(dynamic app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdmitCardDetailPage(application: app),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Admit Cards',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitWave(color: OtrTheme.primaryBlue, size: 30),
            )
          : RefreshIndicator(
              onRefresh: _fetchApplications,
              child: _buildListView(),
            ),
    );
  }

  // --- List View ---
  Widget _buildListView() {
    if (_applications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 60,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No issued admit cards found',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        final app = _applications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'APPLICATION NO',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app['applicationNumber']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: OtrTheme.darkNavy,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ISSUED',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'POST NAME',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                app['postName']?.toString() ?? 'N/A',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: OtrTheme.darkNavy,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToDetail(app),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('VIEW'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: OtrTheme.darkNavy,
                        side: BorderSide(color: Colors.grey.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final String id =
                              (app['applicationUuid'] ??
                                      app['uuid'] ??
                                      app['id'] ??
                                      '')
                                  .toString();
                          final String appNo =
                              (app['applicationNumber'] ?? 'ADMIT_CARD')
                                  .toString()
                                  .replaceAll('/', '_');

                          if (id.isEmpty) {
                            if (mounted) {
                              CustomToast.showError(
                                context,
                                'Invalid application ID',
                              );
                            }
                            return;
                          }

                          final urlString = _apiService.getAdmitCardDownloadUrl(id);
                          CustomToast.showSuccess(context, 'Downloading Admit Card...');

                          // 1. Try downloading from server first
                          List<int>? bytes = await _apiService.downloadAdmitCardBytes(urlString);

                          // 2. If server download fails, fallback to local generation
                          if (bytes == null || bytes.isEmpty) {
                            debugPrint('Server download failed or returned empty, falling back to local generation');
                            if (!mounted) return;
                            CustomToast.showSuccess(context, 'Fetching data for local generation...');
                            
                            final detailResult = await _apiService.getAdmitCard(id);
                            if (!mounted) return;
                            if (detailResult['success'] == true) {
                              CustomToast.showSuccess(context, 'Generating PDF locally...');
                              final fullData = detailResult['data'] ?? {};
                              bytes = await AdmitCardGenerator.generateAdmitCard(fullData);
                            }
                          }

                          if (bytes == null || bytes.isEmpty) {
                            throw 'Failed to get PDF document from server or local generator.';
                          }

                          // 3. Save file
                          await FilePicker.saveFile(
                            dialogTitle: 'Save Admit Card',
                            fileName: 'AdmitCard_$appNo.pdf',
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                            bytes: Uint8List.fromList(bytes!),
                          );

                          if (mounted) {
                            CustomToast.showSuccess(
                              context,
                              'Admit Card saved to device!',
                            );
                          }
                        } catch (e) {
                          if (mounted) CustomToast.showError(context, 'Failed: $e');
                        }
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('DOWNLOAD PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OtrTheme.darkNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
