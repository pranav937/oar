import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../services/api_service.dart';
import '../utils/custom_toast.dart';
import '../utils/admit_card_generator.dart';
import '../theme/otr_theme.dart';

class AdmitCardDetailPage extends StatefulWidget {
  final dynamic application;

  const AdmitCardDetailPage({super.key, required this.application});

  @override
  State<AdmitCardDetailPage> createState() => _AdmitCardDetailPageState();
}

class _AdmitCardDetailPageState extends State<AdmitCardDetailPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _admitCardData;

  @override
  void initState() {
    super.initState();
    _fetchAdmitCardDetail();
  }

  Future<void> _fetchAdmitCardDetail() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final app = widget.application;
      final String id =
          (app['applicationUuid'] ?? app['uuid'] ?? app['id'] ?? '').toString();
      final String appNo = (app['applicationNumber'] ?? '').toString();

      if (id.isEmpty && appNo.isEmpty) {
        throw 'No valid application ID found';
      }

      var response = await _apiService.getAdmitCard(id.isNotEmpty ? id : appNo);

      if (!mounted) return;

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _admitCardData = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        String errorMsg =
            response['message'] ?? 'Admit card not found for this application';
        CustomToast.showError(context, errorMsg);
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomToast.showError(context, 'Error: $e');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'E-Admit Card',
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
              onRefresh: _fetchAdmitCardDetail,
              child: _buildDetailView(),
            ),
    );
  }

  Widget _buildDetailView() {
    if (_admitCardData == null) return const SizedBox();
    final data = _admitCardData!;

    String formattedExamDate = 'N/A';
    try {
      if (data['examDate'] != null) {
        final date = DateTime.parse(data['examDate'].toString());
        formattedExamDate = DateFormat('dd MMM yyyy').format(date);
      }
    } catch (_) {}

    final qrBytes = _getQrBytes(data['qrCodeImage']);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'VERIFIED DIGITAL PERMIT',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (data['hallTicketNumber'] != null)
                Text(
                  data['hallTicketNumber'].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: OtrTheme.darkNavy,
                    fontSize: 12,
                  ),
                )
            ],
          ),
          const SizedBox(height: 20),

          if (qrBytes != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'OFFICIAL QR VERIFICATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Image.memory(
                      qrBytes,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['hallTicketNumber']?.toString() ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: OtrTheme.darkNavy,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SCAN TO VALIDATE AUTHENTICITY',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'CANDIDATE PARTICULARS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailItem(
                                  'FULL LEGAL NAME',
                                  data['candidateName']?.toString() ?? 'N/A',
                                ),
                                const SizedBox(height: 20),
                                _detailItem(
                                  'REGISTRATION ID',
                                  data['registrationId']?.toString() ?? 'N/A',
                                ),
                                const SizedBox(height: 20),
                                _detailItem(
                                  'APPLICATION REFERENCE',
                                  data['applicationNumber']?.toString() ??
                                      'N/A',
                                ),
                                const SizedBox(height: 20),
                                _detailItem(
                                  'POST APPLIED FOR',
                                  data['postName']?.toString() ?? 'N/A',
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                width: 100,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade900,
                                    width: 1.5,
                                  ),
                                  image: data['photoUrl'] != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            data['photoUrl'].toString(),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: data['photoUrl'] == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: data['signatureUrl'] != null
                                    ? Image.network(
                                        data['signatureUrl'].toString(),
                                        fit: BoxFit.contain,
                                      )
                                    : const Center(
                                        child: Text(
                                          'SIGNATURE',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'AUTHORIZED DIGITAL SIGNATURE',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.shade100.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SCHEDULE & LOGISTICS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue.shade700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          _scheduleItem('EXAM DATE', formattedExamDate),
                          _scheduleItem(
                            'REPORTING',
                            data['reportingTime']?.toString() ?? 'N/A',
                            highlight: true,
                          ),
                          _scheduleItem(
                            'GATE CLOSES',
                            data['gateClosingTime']?.toString() ?? 'N/A',
                          ),
                          _scheduleItem(
                            'SHIFT / SESSION',
                            data['examShift']?.toString() ?? 'N/A',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'DESIGNATED ASSESSMENT VENUE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data['examVenueName']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: OtrTheme.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data['examVenueAddress']?.toString() ?? 'N/A',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),  
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _detailItem(
                              'CENTRE CODE',
                              data['examCentreCode']?.toString() ?? 'N/A',
                            ),
                          ),
                          Expanded(
                            child: _detailItem(
                              'SEAT NUMBER',
                              data['seatNumber']?.toString() ?? 'N/A',
                              isBold: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          const SizedBox(height: 30),

          if (data['viewUrl'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final app = widget.application;
                    final String id =
                        (app['applicationUuid'] ??
                                app['uuid'] ??
                                app['id'] ??
                                '')
                            .toString();

                    if (id.isEmpty) {
                      if (!mounted) return;
                      CustomToast.showError(context, 'Invalid application ID');
                      return;
                    }

                    final urlString = _apiService.getAdmitCardDownloadUrl(id);
                    if (!mounted) return;
                    CustomToast.showSuccess(context, 'Loading Hall Ticket...');

                    List<int>? bytes = await _apiService.downloadAdmitCardBytes(
                      urlString,
                    );

                    if (bytes == null || bytes.isEmpty) {
                      if (_admitCardData != null) {
                        if (!mounted) return;
                        CustomToast.showSuccess(
                          context,
                          'Generating view locally...',
                        );
                        bytes = await AdmitCardGenerator.generateAdmitCard(
                          _admitCardData!,
                        );
                      } else {
                        throw 'No data available to generate view.';
                      }
                    }

                    if (bytes.isEmpty) {
                      throw 'Failed to download or generate PDF.';
                    }

                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async =>
                          Uint8List.fromList(bytes!),
                      name:
                          'AdmitCard_${app['applicationNumber'] ?? 'HallTicket'}',
                    );
                  } catch (e) {
                    if (!mounted) return;
                    CustomToast.showError(
                      context,
                      'Error opening print view: $e',
                    );
                  }
                },
                icon: const Icon(Icons.print_rounded),
                label: const Text(
                  'PRINT HALL TICKET',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: OtrTheme.darkNavy,
                  minimumSize: const Size.fromHeight(60),
                  side: const BorderSide(color: OtrTheme.darkNavy, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),

          ElevatedButton.icon(
            onPressed: () async {
              try {
                if (_admitCardData == null) {
                  CustomToast.showError(context, 'Admit card data not loaded');
                  return;
                }

                final app = widget.application;
                final String id =
                    (app['applicationUuid'] ?? app['uuid'] ?? app['id'] ?? '')
                        .toString();
                final String appNo = (app['applicationNumber'] ?? 'ADMIT_CARD')
                    .toString()
                    .replaceAll('/', '_');

                if (id.isEmpty) {
                  CustomToast.showError(context, 'Invalid application ID');
                  return;
                }

                final urlString = _apiService.getAdmitCardDownloadUrl(id);
                if (!mounted) return;
                CustomToast.showSuccess(context, 'Downloading Admit Card...');

                List<int>? bytes = await _apiService.downloadAdmitCardBytes(
                  urlString,
                );

                if (bytes == null || bytes.isEmpty) {
                  if (!mounted) return;
                  CustomToast.showSuccess(
                    context,
                    'Fetching data for local generation...',
                  );

                  final detailResult = await _apiService.getAdmitCard(id);
                  if (detailResult['success'] == true) {
                    if (!mounted) return;
                    CustomToast.showSuccess(
                      context,
                      'Generating PDF locally...',
                    );
                    final fullData = detailResult['data'] ?? {};
                    bytes = await AdmitCardGenerator.generateAdmitCard(
                      fullData,
                    );
                  }
                }

                if (bytes == null || bytes.isEmpty) {
                  throw 'Failed to get PDF document from server or local generator.';
                }

                String? outputFile = await FilePicker.saveFile(
                  dialogTitle: 'Save Admit Card',
                  fileName: 'AdmitCard_$appNo.pdf',
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                  bytes: Uint8List.fromList(bytes),
                );

                if (outputFile != null && mounted) {
                  CustomToast.showSuccess(
                    context,
                    'Admit Card saved to device!',
                  );
                }
              } catch (e) {
                if (mounted) CustomToast.showError(context, 'Generation failed: $e');
              }
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text(
              'DOWNLOAD PDF',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: OtrTheme.darkNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Uint8List? _getQrBytes(String? dataUri) {
    if (dataUri == null) return null;
    try {
      if (dataUri.startsWith('data:image')) {
        final base64String = dataUri.split(',').last;
        return base64Decode(base64String);
      }
      return base64Decode(dataUri);
    } catch (e) {
      debugPrint('Error decoding QR code: $e');
      return null;
    }
  }

  Widget _detailItem(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
            color: OtrTheme.darkNavy,
          ),
        ),
      ],
    );
  }

  Widget _scheduleItem(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: highlight ? Colors.green.shade700 : OtrTheme.darkNavy,
          ),
        ),
      ],
    );
  }
}
