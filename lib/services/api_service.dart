import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic request methods
  Future<http.Response> get(
    String endpoint, {
    bool authenticated = true,
    Map<String, String>? queryParams,
  }) async {
    String? token;
    if (authenticated) {
      token = await _getToken();
    }

    Uri uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(uri, headers: _headers(token));
    return response;
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool authenticated = true,
  }) async {
    String? token;
    if (authenticated) {
      token = await _getToken();
    }
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool authenticated = true,
  }) async {
    String? token;
    if (authenticated) {
      token = await _getToken();
    }
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> delete(
    String endpoint, {
    bool authenticated = true,
  }) async {
    String? token;
    if (authenticated) {
      token = await _getToken();
    }
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers(token),
    );
    return response;
  }

  // --- ORA Candidate Auth ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await post(ApiConstants.candidateLogin, {
        'email': email,
        'password': password,
      }, authenticated: false);

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          if (token != null) {
            await _saveToken(token);
          }
        }
        return data.containsKey('success')
            ? data
            : {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> vendorLogin(
    String email,
    String password,
  ) async {
    try {
      final response = await post(
        ApiConstants.vendorLogin,
        {
          'contactEmail': email,
          'password': password,
        },
        authenticated: false,
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          if (token != null) {
            await _saveToken(token);
          }
        }
        return data.containsKey('success')
            ? data
            : {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Vendor login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
    Map<String, dynamic> candidateData,
  ) async {
    try {
      final response = await post(
        ApiConstants.candidateRegister,
        candidateData,
        authenticated: false,
      );

      debugPrint(
        "DEBUG: Registration Response (${response.statusCode}): ${response.body}",
      );
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data.containsKey('success')
            ? data
            : {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'data': data,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> vendorRegister(
    Map<String, dynamic> vendorData,
  ) async {
    try {
      final response = await post(
        ApiConstants.vendorRegister,
        vendorData,
        authenticated: false,
      );

      debugPrint(
        "DEBUG: Vendor Registration Response (${response.statusCode}): ${response.body}",
      );
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data.containsKey('success')
            ? data
            : {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Vendor registration failed',
          'data': data,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    try {
      final response = await post(ApiConstants.candidateSendOtp, {
        'email': email,
      }, authenticated: false);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp(String email, String otp) async {
    try {
      final response = await post(ApiConstants.candidateVerifyOtp, {
        'email': email,
        'otp': otp,
      }, authenticated: false);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendMobileOtp(String mobileNumber) async {
    try {
      final response = await post(ApiConstants.candidateSendMobileOtp, {
        'mobileNumber': mobileNumber,
      }, authenticated: false);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyMobileOtp(
    String mobileNumber,
    String otp,
  ) async {
    try {
      final response = await post(ApiConstants.candidateVerifyMobileOtp, {
        'mobileNumber': mobileNumber,
        'otp': otp,
      }, authenticated: false);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String mobileNumber) async {
    try {
      final response = await post(ApiConstants.candidateForgotPassword, {
        'mobileNumber': mobileNumber,
      }, authenticated: false);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String mobileNumber,
    String newPassword,
    String confirmPassword,
    String otp,
  ) async {
    try {
      final response = await post(ApiConstants.candidateResetPassword, {
        'mobileNumber': mobileNumber,
        'newPassword': newPassword,
        'password': newPassword, // Retained just in case
        'confirmPassword': confirmPassword,
        'password_confirmation': confirmPassword,
        'otp': otp,
      }, authenticated: false);

      debugPrint(
        'DEBUG RESET PASSWORD: ${response.statusCode} - ${response.body}',
      );
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      String parseMessage(dynamic msg) {
        if (msg is List) return msg.join(', ');
        return msg?.toString() ?? 'Failed to reset password';
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded.containsKey('success')
            ? decoded
            : {
                'success': true,
                'data': decoded,
                'message': decoded['message'] != null
                    ? parseMessage(decoded['message'])
                    : 'Password reset successfully',
              };
      } else {
        return {'success': false, 'message': parseMessage(decoded['message'])};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- ORA Dashboard & Profile ---

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await get(ApiConstants.candidateDashboard);
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data.containsKey('success')
            ? data
            : {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch dashboard',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await get(ApiConstants.candidateProfile);
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data.containsKey('success')
            ? data
            : {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await put(ApiConstants.candidateProfile, profileData);
      final Map<String, dynamic> data = jsonDecode(response.body);

      String parseMsg(dynamic body) {
        if (body['errors'] != null) {
          if (body['errors'] is List) {
            return body['errors']
                .map((e) {
                  if (e is Map) {
                    return "${e['field'] ?? ''}: ${e['message'] ?? e.toString()}";
                  }
                  return e.toString();
                })
                .join('\n');
          }
          if (body['errors'] is Map) {
            return body['errors'].entries
                .map((e) {
                  final val = e.value;
                  return "${e.key}: ${val is List ? val.join(', ') : val}";
                })
                .join('\n');
          }
          return body['errors'].toString();
        }
        if (body['error'] != null) return body['error'].toString();
        var msg = body['message'];
        if (msg is List) return msg.join(', ');
        if (msg != null && msg.toString().isNotEmpty) return msg.toString();
        return 'Update failed (Error ${response.statusCode})';
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data.containsKey('success')
            ? data
            : {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': parseMsg(data)};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- ORA File Uploads ---

  Future<Map<String, dynamic>> uploadPhoto(File file) async {
    return _uploadMultipartFile(
      file,
      ApiConstants.candidateUploadPhoto,
      'photo',
    );
  }

  Future<Map<String, dynamic>> uploadSignature(File file) async {
    return _uploadMultipartFile(
      file,
      ApiConstants.candidateUploadSignature,
      'signature',
    );
  }

  Future<Map<String, dynamic>> deletePhoto() async {
    try {
      final response = await delete(ApiConstants.candidateDeletePhoto);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteSignature() async {
    try {
      final response = await delete(ApiConstants.candidateDeleteSignature);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> _uploadMultipartFile(
    File file,
    String endpoint,
    String fieldName, {
    Map<String, String>? extraFields,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Auth token not found'};
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      // Add extra fields (like documentType, documentName)
      if (extraFields != null) {
        request.fields.addAll(extraFields);
      }

      final length = await file.length();

      // Enforce 5MB limit
      if (length > 5 * 1024 * 1024) {
        return {'success': false, 'message': 'File size must not exceed 5 MB'};
      }

      final stream = http.ByteStream(file.openRead());

      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final contentType = MediaType.parse(mimeType);

      final multipartFile = http.MultipartFile(
        fieldName,
        stream,
        length,
        filename: file.path.split('/').last,
        contentType: contentType,
      );

      request.files.add(multipartFile);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final decoded = jsonDecode(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded.containsKey('success')
            ? decoded
            : {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- ORA Jobs & Applications ---

  Future<Map<String, dynamic>> getJobs() async {
    final response = await get(ApiConstants.advertisementsActive);
    final decoded = jsonDecode(response.body);
    return decoded;
  }

  Future<Map<String, dynamic>> getApplicationForm(
    String advertisementUuid,
  ) async {
    try {
      final response = await get(
        ApiConstants.applicationForm,
        queryParams: {'advertisementUuid': advertisementUuid},
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return decoded;
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to load form',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getExamCentres() async {
    try {
      final response = await get(ApiConstants.examCentres);
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return decoded.containsKey('success')
            ? decoded
            : {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to load exam centres',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> submitApplication(
    Map<String, dynamic> appData,
  ) async {
    try {
      debugPrint('DEBUG SUBMIT APPDATA: $appData');
      final response = await post(ApiConstants.applicationSubmit, appData);
      debugPrint('DEBUG SUBMIT APP: ${response.statusCode} - ${response.body}');
      final decoded = jsonDecode(response.body);

      String parseMsg(dynamic body) {
        // 1. Try to get specific errors array first
        if (body['errors'] != null) {
          if (body['errors'] is List) {
            return body['errors']
                .map((e) {
                  if (e is Map) {
                    return "${e['field'] ?? ''}: ${e['message'] ?? e.toString()}";
                  }
                  return e.toString();
                })
                .join('\n');
          }
          if (body['errors'] is Map) {
            return body['errors'].entries
                .map((e) {
                  final val = e.value;
                  return "${e.key}: ${val is List ? val.join(', ') : val}";
                })
                .join('\n');
          }
          return body['errors'].toString();
        }

        // 2. Try 'error' field
        if (body['error'] != null) return body['error'].toString();

        // 3. Try main 'message'
        var msg = body['message'];
        if (msg is List) return msg.join(', ');
        if (msg != null && msg.toString().isNotEmpty) return msg.toString();

        return 'Submission failed (Error ${response.statusCode})';
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        return {'success': false, 'message': parseMsg(decoded)};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMyApplications({
    int page = 1,
    int pageSize = 10,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (status != null && status != 'ALL') {
        queryParams['status'] = status;
      }

      final response = await get(
        ApiConstants.myApplications,
        queryParams: queryParams,
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return decoded;
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to load applications',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- ORA Payments ---

  Future<Map<String, dynamic>> initiatePayment(
    String applicationUuid,
    double amount,
    String paymentMode,
  ) async {
    try {
      final body = {
        'applicationUuid': applicationUuid,
        'amount': amount.toInt(),
        'paymentMode': paymentMode,
      };
      final response = await post('/api/ora/payments/initiate', body);
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Payment initiation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyPayment(
    String transactionId,
    String gatewayTransactionId,
    double amount,
    String status,
  ) async {
    try {
      final body = {
        'transactionId': transactionId,
        'gatewayTransactionId': gatewayTransactionId,
        'status': status,
        'amount': amount.toInt(),
        'responseCode': 'OK',
      };
      final response = await post('/api/ora/payments/verify-callback', body);
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Payment verification failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAppliedRecruitments({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await get(
        ApiConstants.myApplications,
        queryParams: {'page': page.toString(), 'pageSize': pageSize.toString()},
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return decoded;
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to fetch applications',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getPaymentHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await get(
        '/api/ora/payments/history',
        queryParams: {'page': page.toString(), 'pageSize': pageSize.toString()},
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return decoded;
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to fetch payment history',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Simulator helper (Optional but helpful for ORA flow)
  Future<Map<String, dynamic>> simulatePayment(String transactionId) async {
    try {
      final response = await post('/api/ora/payments/$transactionId/simulate', {
        'status': 'SUCCESS',
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Simulation error: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadDocument(File file, String type) async {
    return _uploadMultipartFile(
      file,
      ApiConstants.candidateUploadDocs,
      'document',
      extraFields: {
        'documentType': type,
        'documentName': file.path.split('/').last,
      },
    );
  }

  Future<Map<String, dynamic>> getDocuments() async {
    try {
      final response = await get(ApiConstants.candidateUploadDocs);
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return decoded.containsKey('success')
            ? decoded
            : {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to fetch documents',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteDocument(String type) async {
    try {
      final response = await delete(
        '${ApiConstants.candidateUploadDocs}?documentType=$type',
      );

      // Handle empty body
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true, 'message': 'Deleted successfully'};
        }
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }

      // Safe JSON decode
      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true, 'message': 'Deleted successfully'};
        }
        return {'success': false, 'message': 'Invalid server response'};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded.containsKey('success')
            ? decoded
            : {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to delete document',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // Fetch Notifications
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await get('/api/notifications/me?page=1&pageSize=20');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      debugPrint('Error loading notifications');
      return {'success': false, 'message': 'Failed to load notifications'};
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAdmitCard(String applicationUuid) async {
    try {
      final response = await get(
        '${ApiConstants.admitCardFetch}/$applicationUuid',
      );

      // Check if the response is HTML (starts with <!DOCTYPE or <html)
      final body = response.body.trim();
      if (body.startsWith('<!DOCTYPE') || body.startsWith('<html')) {
        return {
          'success': false,
          'message':
              'Server error: Invalid response format (HTML instead of JSON). Status: ${response.statusCode}',
        };
      }

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        return {
          'success': false,
          'message':
              decoded['message'] ??
              'Failed to fetch admit card (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  String getAdmitCardDownloadUrl(String applicationUuid) {
    // Use /download-pdf suffix as per user requirement
    return '${ApiConstants.baseUrl}${ApiConstants.admitCardFetch}/$applicationUuid/download-pdf';
  }

  Future<List<int>?> downloadAdmitCardBytes(String url) async {
    try {
      final token = await _getToken();
      // Using GET as specified by the user's API requirement
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Accept': 'application/pdf',
            },
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        // Check if the file starts with the PDF magic number '%PDF-'
        if (bytes.length > 4 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46) {
          return bytes;
        }

        debugPrint(
          "Download failed: Response is not a valid PDF. Status: ${response.statusCode}",
        );
        return null;
      }

      // Fallback to GET if POST fails (for non-standard endpoints)
      final getResponse = await http
          .get(
            Uri.parse(url),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Accept': 'application/pdf',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (getResponse.statusCode == 200) {
        final bytes = getResponse.bodyBytes;
        if (bytes.length > 4 && bytes[0] == 0x25) return bytes;
      }

      return null;
    } catch (e) {
      debugPrint("PDF Download Exception: $e");
      return null;
    }
  }

  // --- Master Data ---
  Future<Map<String, dynamic>> getStates() async {
    try {
      final response = await get(
        ApiConstants.masterStates,
        authenticated: false,
      );
      final decoded = jsonDecode(response.body);
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getCities(String stateCode) async {
    try {
      final response = await get(
        "${ApiConstants.masterCities}/$stateCode",
        authenticated: false,
      );
      final decoded = jsonDecode(response.body);
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- Vendor EOIs ---
  Future<Map<String, dynamic>> getVendorEOIs({String status = 'PUBLISHED'}) async {
    try {
      final response = await get(
        ApiConstants.vendorEOIs,
        queryParams: {'status': status},
      );
      final decoded = jsonDecode(response.body);
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getVendorBids() async {
    try {
      final response = await get(ApiConstants.vendorBids);
      final decoded = jsonDecode(response.body);
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> submitBid(Map<String, dynamic> bidData) async {
    try {
      final response = await post(
        ApiConstants.vendorBids,
        bidData,
        authenticated: true,
      );
      final decoded = jsonDecode(response.body);
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getVendorProfile() async {
    try {
      final response = await get(ApiConstants.vendorProfile);
      final decoded = jsonDecode(response.body);
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getVendorPerformance() async {
    try {
      final response = await get(ApiConstants.vendorPerformance);
      final decoded = jsonDecode(response.body);
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getVendorWorkOrders() async {
    try {
      final response = await get(ApiConstants.vendorWorkOrders);
      final decoded = jsonDecode(response.body);
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
