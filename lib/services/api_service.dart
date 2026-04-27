import 'dart:io';
import 'dart:convert';
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

  Future<Map<String, dynamic>> register(
    Map<String, dynamic> candidateData,
  ) async {
    try {
      final response = await post(
        ApiConstants.candidateRegister,
        candidateData,
        authenticated: false,
      );

      print(
        "DEBUG: Registration Response (${response.statusCode}): ${response.body}",
      );
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Check for success - the API usually returns 200 or 201 for success
      // If the API response structure has 'success' field, we use that
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data.containsKey('success')
            ? data
            : {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
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
      if (token == null)
        return {'success': false, 'message': 'Auth token not found'};

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

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
        return {'success': false, 'message': decoded['message'] ?? 'Failed to load form'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> submitApplication(
    Map<String, dynamic> appData,
  ) async {
    try {
      final response = await post(ApiConstants.applicationSubmit, appData);
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        return {'success': false, 'message': decoded['message'] ?? 'Submission failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMyApplications({
    int page = 1,
    int pageSize = 10,
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
        return {'success': false, 'message': decoded['message'] ?? 'Failed to load applications'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- ORA Payments ---

  Future<Map<String, dynamic>> initiatePayment(
    String appUuid,
    double amount,
  ) async {
    final response = await post(ApiConstants.initiatePayment, {
      'applicationUuid': appUuid,
      'amount': amount,
      'paymentMode': 'ONLINE',
    });
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyPayment(
    String paymentUuid,
    String transactionId,
  ) async {
    // Stub for offline mode
    return {'success': true, 'message': 'Payment verified (Offline)'};
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
