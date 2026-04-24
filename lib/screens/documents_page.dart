import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final Map<String, String> _documentMap = {'Aadhaar Card': 'AADHAAR'};

  @override
  void initState() {
    super.initState();
    _fetchInitialDocs();
  }

  Future<void> _fetchInitialDocs() async {
    try {
      final result = await _apiService.getDocuments();
      if (result['success'] == true && result['data'] != null) {
        final List docs = result['data'];
        setState(() {
          for (var doc in docs) {
            final String? type = doc['documentType'];
            final String? name = doc['documentName'];
            final String? url = doc['url'];

            // Reverse mapping from Type (AADHAAR) back to Title (Aadhaar Card)
            String? title;
            _documentMap.forEach((key, value) {
              if (value == type) title = key;
            });

            if (title != null) {
              _uploadedDocs[title!] = {'name': name, 'url': url};
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching docs: $e");
    }
  }

  void _showSourceOptions(String docTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload $docTitle',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
        if (image != null) {
          pickedPath = image.path;
          pickedName = image.name;
        }
      } else {
        FilePickerResult? result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        );
        if (result != null) {
          pickedPath = result.files.single.path;
          pickedName = result.files.single.name;
        }
      }

      if (pickedPath != null) {
        _uploadToServer(docTitle, pickedPath, pickedName!);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _uploadToServer(
    String docTitle,
    String path,
    String name,
  ) async {
    setState(() {
      _isUploading = true;
      _uploadingFor = docTitle;
    });

    try {
      final String docType = _documentMap[docTitle] ?? 'OTHER';
      final result = await _apiService.uploadDocument(File(path), docType);

      if (result['success'] == true) {
        setState(() {
          final data = result['data'] as Map<String, dynamic>?;
          _uploadedDocs[docTitle] = {
            'path': path,
            'name': name,
            'url': data?['fileUrl'] ?? data?['url'],
          };
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] as String? ?? 'Upload failed'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
        title: const Text(
          'Documentation',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Upload required documents for profile verification.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ..._documentMap.keys.map((doc) => _buildDocCard(doc)).toList(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OtrTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'FINISH SETUP',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isUploaded
              ? Colors.green.withOpacity(0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUploaded ? Icons.done_all_rounded : Icons.upload_file_rounded,
              color: isUploaded ? Colors.green : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUploaded
                      ? (_uploadedDocs[docTitle]!['name'] ?? 'File uploaded')
                      : 'Verification pending',
                  style: TextStyle(
                    fontSize: 11,
                    color: isUploaded
                        ? OtrTheme.darkNavy
                        : Colors.grey.shade300,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isThisUploading)
            const SpinKitThreeBounce(color: OtrTheme.primaryBlue, size: 16)
          else if (isUploaded)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _viewDocument(docTitle),
                  icon: const Icon(
                    Icons.visibility_outlined,
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _updateDocument(docTitle),
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: OtrTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _deleteDocument(docTitle),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ],
            )
          else
            TextButton(
              onPressed: () => _showSourceOptions(docTitle),
              style: TextButton.styleFrom(
                backgroundColor: OtrTheme.primaryBlue.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'UPLOAD',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _viewDocument(String docTitle) async {
    String? url = _uploadedDocs[docTitle]?['url'];

    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document URL not found. Please re-upload.'),
          ),
        );
      }
      return;
    }

    // Safely join Base URL and relative path
    String fullUrl = url;
    if (!url.startsWith('http')) {
      final String base = ApiConstants.baseUrl.endsWith('/')
          ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
          : ApiConstants.baseUrl;
      final String path = url.startsWith('/') ? url : '/$url';
      fullUrl = '$base$path';
    }

    final Uri uri = Uri.parse(fullUrl);
    try {
      // Trying direct launch first (more reliable on newer Android versions)
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback check
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open browser. Try copying the link.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Browser Error: $e')));
      }
    }
  }

  void _updateDocument(String docTitle) {
    _showSourceOptions(docTitle);
  }

  void _deleteDocument(String docTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Document?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to remove your $docTitle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _uploadedDocs.remove(docTitle));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document removed!')),
              );
            },
            child: const Text(
              'DELETE',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
