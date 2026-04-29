import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/custom_toast.dart';
import '../theme/otr_theme.dart';

class AdmitCardPage extends StatefulWidget {
  const AdmitCardPage({Key? key}) : super(key: key);

  @override
  State<AdmitCardPage> createState() => _AdmitCardPageState();
}

class _AdmitCardPageState extends State<AdmitCardPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _admitCard;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final String? uuid = (args is String) ? args : null;
      if (uuid != null) {
        _fetchAdmitCard(uuid);
      } else {
        setState(() {
          _isLoading = false;
        });
        CustomToast.showError(context, 'Application ID missing');
      }
    }
  }

  Future<void> _fetchAdmitCard(String uuid) async {
    try {
      final response = await _apiService.getAdmitCard(uuid);
      if (response['success'] == true) {
        setState(() {
          _admitCard = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        CustomToast.showError(
          context,
          response['message'] ?? 'Failed to load admit card',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      CustomToast.showError(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: OtrTheme.background,
        body: const Center(
          child: SpinKitWave(color: OtrTheme.primaryBlue, size: 30),
        ),
      );
    }

    if (_admitCard == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('E-Admit Card')),
        body: const Center(child: Text('No data found')),
      );
    }

    final data = _admitCard!;

    // Formatting Date
    String formattedExamDate = 'N/A';
    try {
      final date = DateTime.parse(data['examDate']);
      formattedExamDate = DateFormat('EEEE, d MMMM yyyy').format(date);
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'E-Admit Card',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: () =>
                CustomToast.showSuccess(context, 'Preparing print version...'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Hall Ticket Card ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: OtrTheme.darkNavy,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'JADE EDU RECRUITMENT CELL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'ADMIT CARD FOR WRITTEN EXAMINATION',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Photo & Signature Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Identity Labels
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ticketItem(
                                'ROLL NUMBER',
                                data['hallTicketNumber'] ?? 'N/A',
                                isBold: true,
                              ),
                              const SizedBox(height: 12),
                              _ticketItem(
                                'REGISTRATION ID',
                                data['registrationId'] ?? 'N/A',
                              ),
                              const SizedBox(height: 12),
                              _ticketItem(
                                'CANDIDATE NAME',
                                data['candidateName']?.toUpperCase() ?? 'N/A',
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                        // Right: Photo
                        Column(
                          children: [
                            Container(
                              width: 90,
                              height: 110,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.grey.shade50,
                              ),
                              child: data['photoUrl'] != null
                                  ? Image.network(
                                      data['photoUrl'],
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(height: 4),
                            // Signature
                            Container(
                              width: 90,
                              height: 35,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                              child: data['signatureUrl'] != null
                                  ? Image.network(
                                      data['signatureUrl'],
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
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Divider(height: 1),
                  ),

                  // Post Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ticketItem(
                            'POST APPLIED',
                            data['postName'] ?? 'N/A',
                          ),
                        ),
                        Expanded(
                          child: _ticketItem(
                            'ADV NO.',
                            data['advertisementNumber'] ?? 'N/A',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Divider(height: 1),
                  ),

                  // Exam Schedule
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ticketItem(
                                'EXAM DATE',
                                formattedExamDate,
                                icon: Icons.calendar_today_rounded,
                              ),
                            ),
                            Expanded(
                              child: _ticketItem(
                                'SHIFT',
                                data['examShift'] ?? 'N/A',
                                icon: Icons.schedule_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ticketItem(
                                'REPORTING TIME',
                                data['reportingTime'] ?? 'N/A',
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Expanded(
                              child: _ticketItem(
                                'GATE CLOSING',
                                data['gateClosingTime'] ?? 'N/A',
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Divider(height: 1),
                  ),

                  // Venue
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ticketItem(
                          'EXAMINATION CENTRE',
                          data['examVenueName'] ?? 'N/A',
                          isBold: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['examVenueAddress'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ticketItem(
                                'CENTRE CODE',
                                data['examCentreCode'] ?? 'N/A',
                              ),
                            ),
                            Expanded(
                              child: _ticketItem(
                                'SEAT NUMBER',
                                data['seatNumber'] ?? 'N/A',
                                isBold: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Barcode Mock
                  Container(
                    height: 40,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          40,
                          (index) => Container(
                            width: (index % 3 == 0) ? 3 : 1,
                            height: 25,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['admitCardUuid']?.substring(0, 8).toUpperCase() ?? '',
                    style: const TextStyle(
                      fontSize: 9,
                      letterSpacing: 2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Instructions Section ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: OtrTheme.primaryBlue,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'IMPORTANT INSTRUCTIONS',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (data['instructions'] is List)
                    ...(data['instructions'] as List).map(
                      (inst) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: OtrTheme.primaryBlue,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                inst.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Print Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () =>
                    CustomToast.showSuccess(context, 'Downloading PDF...'),
                icon: const Icon(Icons.file_download_outlined),
                label: const Text(
                  'DOWNLOAD ADMIT CARD (PDF)',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OtrTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _ticketItem(
    String label,
    String value, {
    bool isBold = false,
    IconData? icon,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: OtrTheme.primaryBlue),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                  color: color ?? OtrTheme.darkNavy,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
