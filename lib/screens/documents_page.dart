import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  // Storing server responses or paths: {DocumentType: {path: '...', serverUrl: '...'}}
  final Map<String, Map<String, dynamic>> _uploadedDocs = {};
  bool _isUploading = false;
  String? _uploadingFor;

  final Map<String, String> _documentMap = {
    'Passport Photo': 'PHOTO',
    'Signature': 'SIGNATURE',
    'Aadhaar Card': 'AADHAAR',
    'PAN Card': 'PAN',
    '10th Certificate': '10TH_CERT',
    '12th Certificate': '12TH_CERT',
    'Graduate Degree': 'GRAD_DEGREE',
  };

  void _showSourceOptions(String docTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload $docTitle', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => _handlePick(docTitle, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => _handlePick(docTitle, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Document (PDF)'),
              onTap: () => _handlePick(docTitle, null),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePick(String docTitle, ImageSource? source) async {
    Navigator.pop(context);
    String? pickedPath;
    String? pickedName;

    try {
      if (source != null) {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) { pickedPath = image.path; pickedName = image.name; }
      } else {
        FilePickerResult? result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
        if (result != null) { pickedPath = result.files.single.path; pickedName = result.files.single.name; }
      }

      if (pickedPath != null) {
        _uploadToServer(docTitle, pickedPath, pickedName!);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _uploadToServer(String docTitle, String path, String name) async {
    setState(() {
      _isUploading = true;
      _uploadingFor = docTitle;
    });

    try {
      // Mocking the upload for offline demo
      await Future.delayed(const Duration(seconds: 1));
      final Map<String, dynamic> result = {
        'success': true,
        'message': 'Uploaded successfully (Offline Mode)',
        'data': {'fileUrl': 'https://example.com/mock_file.pdf'}
      };
      
      if (result['success'] == true) {
        setState(() {
          final data = result['data'] as Map<String, dynamic>?;
          _uploadedDocs[docTitle] = {
            'path': path,
            'name': name,
            'url': data?['fileUrl'],
          };
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded successfully!'), backgroundColor: Colors.green));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] as String? ?? 'Upload failed')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading: $e')));
    } finally {
      setState(() {
        _isUploading = false;
        _uploadingFor = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text('Documentation', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Upload required documents for profile verification.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            ..._documentMap.keys.map((doc) => _buildDocCard(doc)).toList(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OtrTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('FINISH SETUP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(String docTitle) {
    final bool isUploaded = _uploadedDocs.containsKey(docTitle);
    final bool isThisUploading = _isUploading && _uploadingFor == docTitle;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(isUploaded ? Icons.check_circle : Icons.upload_file, color: isUploaded ? Colors.green : Colors.grey),
          const SizedBox(width: 16),
          Expanded(child: Text(docTitle, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (isThisUploading)
            const SpinKitThreeBounce(color: OtrTheme.primaryBlue, size: 20)
          else if (isUploaded)
            const Text('Done', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
          else
            TextButton(onPressed: () => _showSourceOptions(docTitle), child: const Text('UPLOAD')),
        ],
      ),
    );
  }
}
