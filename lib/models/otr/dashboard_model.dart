import '../../utils/constants.dart';

class DashboardStats {
  final String uuid;
  final String registrationId;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String category;
  final String? photoUrl;
  final int totalApplications;
  final int pendingApplications;
  final String registrationStatus;

  DashboardStats({
    required this.uuid,
    required this.registrationId,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.category,
    this.photoUrl,
    required this.totalApplications,
    required this.pendingApplications,
    required this.registrationStatus,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    String? photoPath = json['photoUrl'];
    if (photoPath != null && !photoPath.startsWith('http')) {
      photoPath = '${ApiConstants.baseUrl}$photoPath';
    }

    return DashboardStats(
      uuid: json['uuid'] ?? '',
      registrationId: json['registrationId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      category: json['category'] ?? '',
      photoUrl: photoPath,
      totalApplications: json['totalApplications'] ?? 0,
      pendingApplications: json['pendingApplications'] ?? 0,
      registrationStatus: json['registrationStatus'] ?? '',
    );
  }
}
