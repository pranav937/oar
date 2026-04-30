import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'constants.dart';

class AdmitCardGenerator {
  static String _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    
    final String base = ApiConstants.baseUrl.endsWith('/')
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
        : ApiConstants.baseUrl;
    final String path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
  }

  static Future<Uint8List> generateAdmitCard(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.interBold();
    final fontRegular = await PdfGoogleFonts.interRegular();

    // Pre-fetch images with URL resolution
    pw.ImageProvider? photoProvider;
    pw.ImageProvider? signatureProvider;

    final String photoUrl = _resolveUrl(data['photoUrl']?.toString() ?? 
                            data['candidate']?['photoUrl']?.toString() ??
                            data['personalDetails']?['photoUrl']?.toString());
    
    final String signatureUrl = _resolveUrl(data['signatureUrl']?.toString() ?? 
                               data['candidate']?['signatureUrl']?.toString() ??
                               data['personalDetails']?['signatureUrl']?.toString());

    try {
      if (photoUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(photoUrl));
        if (response.statusCode == 200) {
          photoProvider = pw.MemoryImage(response.bodyBytes);
        }
      }
      if (signatureUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(signatureUrl));
        if (response.statusCode == 200) {
          signatureProvider = pw.MemoryImage(response.bodyBytes);
        }
      }
    } catch (e) {
      print('Error fetching images for PDF: $e');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Watermark
              pw.Center(
                child: pw.Opacity(
                  opacity: 0.05,
                  child: pw.Transform.rotate(
                    angle: 0.5,
                    child: pw.Text(
                      'OFFICIAL DOCUMENT',
                      style: pw.TextStyle(
                        fontSize: 60,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 10),

                  // Document Title
                  pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue900,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'e-ADMIT CARD (HALL TICKET)',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // Candidate Info & Photo
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildInfoField('FULL NAME', data['candidateName']?.toString().toUpperCase() ?? 'N/A', font),
                            pw.SizedBox(height: 12),
                            pw.Row(
                              children: [
                                pw.Expanded(child: _buildInfoField('APPLICATION NO', data['applicationNumber']?.toString() ?? 'N/A', font)),
                                pw.Expanded(child: _buildInfoField('ROLL NUMBER', data['rollNumber']?.toString() ?? 'PENDING', font)),
                              ],
                            ),
                            pw.SizedBox(height: 12),
                            pw.Row(
                              children: [
                                pw.Expanded(child: _buildInfoField('CATEGORY', data['category']?.toString() ?? 'UR', font)),
                                pw.Expanded(child: _buildInfoField('GENDER', data['gender']?.toString() ?? 'N/A', font)),
                              ],
                            ),
                            pw.SizedBox(height: 12),
                            _buildInfoField('DATE OF BIRTH', data['dateOfBirth']?.toString().split('T')[0] ?? 'N/A', font),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 100,
                            height: 120,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey400),
                            ),
                            child: photoProvider != null 
                              ? pw.Image(photoProvider, fit: pw.BoxFit.cover)
                              : pw.Center(
                                  child: pw.Text('PHOTO', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400)),
                                ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Container(
                            width: 100,
                            height: 40,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey400),
                            ),
                            child: signatureProvider != null
                              ? pw.Image(signatureProvider, fit: pw.BoxFit.contain)
                              : pw.Center(
                                  child: pw.Text('SIGNATURE', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400)),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 10),

                  // Post Info
                  _buildInfoField('POST APPLIED FOR', data['postName']?.toString().toUpperCase() ?? 'N/A', font, isFullWidth: true),

                  pw.SizedBox(height: 20),

                  // Exam Logistics
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'EXAMINATION LOGISTICS',
                          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.blue900),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            pw.Expanded(child: _buildInfoField('EXAM DATE', data['examDate']?.toString() ?? 'N/A', font)),
                            pw.Expanded(child: _buildInfoField('REPORTING TIME', data['reportingTime']?.toString() ?? 'N/A', font)),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            pw.Expanded(child: _buildInfoField('GATE CLOSING', data['gateClosingTime']?.toString() ?? 'N/A', font)),
                            pw.Expanded(child: _buildInfoField('SHIFT / SESSION', data['examShift']?.toString() ?? 'N/A', font)),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        _buildInfoField('EXAMINATION VENUE', data['examVenueName']?.toString() ?? 'N/A', font, isFullWidth: true),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          data['examVenueAddress']?.toString() ?? '',
                          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            pw.Expanded(child: _buildInfoField('CENTRE CODE', data['examCentreCode']?.toString() ?? 'N/A', font)),
                            pw.Expanded(child: _buildInfoField('SEAT NUMBER', data['seatNumber']?.toString() ?? 'N/A', font)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // Important Instructions
                  pw.Text(
                    'IMPORTANT INSTRUCTIONS FOR CANDIDATES',
                    style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.blue900),
                  ),
                  pw.SizedBox(height: 8),
                  _instructionItem('1. Candidates must bring this Admit Card along with an original Photo ID proof.'),
                  _instructionItem('2. Please reach the examination center at least 60 minutes before the reporting time.'),
                  _instructionItem('3. Electronic gadgets, mobile phones, and calculators are strictly prohibited.'),
                  _instructionItem('4. The candidate signature must match the one uploaded during registration.'),

                  pw.Spacer(),

                  // Footer / QR Code
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Date of Issue: ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                          ),
                          pw.Text(
                            'System Generated Document - No Signature Required',
                            style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                      pw.Container(
                        width: 50,
                        height: 50,
                        color: PdfColors.grey200,
                        child: pw.Center(child: pw.Text('QR', style: const pw.TextStyle(fontSize: 8))),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoField(String label, String value, pw.Font font, {bool isFullWidth = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.black),
        ),
      ],
    );
  }

  static pw.Widget _instructionItem(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: const pw.TextStyle(fontSize: 8)),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
