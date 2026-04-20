import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

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
  Future<http.Response> get(String endpoint, {bool authenticated = true, Map<String, String>? queryParams}) async {
    String? token;
    if (authenticated) {
      token = await _getToken();
    }
    
    Uri uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(
      uri,
      headers: _headers(token),
    );
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool authenticated = true}) async {
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

  Future<http.Response> put(String endpoint, Map<String, dynamic> body, {bool authenticated = true}) async {
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

  // --- ORA Candidate Auth ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Mock for offline mode
    await Future.delayed(const Duration(milliseconds: 500));
    await _saveToken("mock_access_token");
    return {'success': true, 'message': 'Login successful (Offline)', 'data': {'token': 'mock_access_token'}};
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> candidateData) async {
    // Mock for offline mode
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, 'message': 'Registration successful (Offline)'};
  }

  Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    // Mock for offline mode
    return {'success': true, 'message': 'OTP sent (Offline)'};
  }

  Future<Map<String, dynamic>> verifyEmailOtp(String email, String otp) async {
    // Mock for offline mode
    return {'success': true, 'message': 'OTP verified (Offline)'};
  }

  // --- ORA Dashboard & Profile ---

  Future<Map<String, dynamic>> getDashboard() async {
    // Mock for offline mode
    return {
      'success': true,
      'data': {
        'totalApplications': 5,
        'approvedApplications': 2,
        'pendingApplications': 3
      }
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    // Mock for offline mode
    return {
      'success': true,
      'data': {
        'fullname': 'Demo User',
        'email': 'demo@example.com',
        'mobileNumber': '9876543210',
        'permanentAddress': '123 Main St, City',
        'state': 'Bihar',
        'district': 'Patna',
        'pinCode': '800001'
      }
    };
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    // Mock for offline mode
    return {'success': true, 'message': 'Profile updated (Offline)'};
  }

  // --- ORA Jobs & Applications ---

  Future<Map<String, dynamic>> getJobs() async {
    // Mock for offline mode
    return {
      'success': true,
      'data': [
        {
          'uuid': 'job1',
          'title': 'Junior Associate',
          'department': 'Operations',
          'applicationFee': 500.0,
          'lastDate': '2026-05-20'
        },
        {
          'uuid': 'job2',
          'title': 'Field Officer',
          'department': 'Logistics',
          'applicationFee': 400.0,
          'lastDate': '2026-05-25'
        }
      ]
    };
  }

  Future<Map<String, dynamic>> getApplicationForm(String advertisementUuid) async {
    // Mock for offline mode
    return {
      'success': true,
      'data': {
        'formFields': [] 
      }
    };
  }

  Future<Map<String, dynamic>> submitApplication(Map<String, dynamic> appData) async {
    // Mock for offline mode
    return {
      'success': true,
      'message': 'Application submitted (Offline)',
      'data': {'applicationUuid': 'mock_app_uuid'}
    };
  }

  Future<Map<String, dynamic>> getMyApplications({int page = 1, int pageSize = 10}) async {
    // Mock for offline mode
    return {
      'success': true,
      'data': []
    };
  }

  // --- ORA Payments ---

  Future<Map<String, dynamic>> initiatePayment(String appUuid, double amount) async {
    final response = await post(ApiConstants.initiatePayment, {
      'applicationUuid': appUuid,
      'amount': amount,
      'paymentMode': 'ONLINE'
    });
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyPayment(String paymentUuid, String transactionId) async {
    // Stub for offline mode
    return {'success': true, 'message': 'Payment verified (Offline)'};
  }

  Future<Map<String, dynamic>> uploadDocument(File file, String type) async {
    // Stub for offline mode
    return {
      'success': true, 
      'message': 'Document uploaded (Offline)',
      'data': {'fileUrl': 'https://example.com/mock_file.pdf'}
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
