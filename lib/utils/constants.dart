class ApiConstants {
  static const String baseUrl = "http://192.168.1.9:8000"; // Default base URL, can be updated

  // ORA Candidate Endpoints
  static const String candidateRegister = "/api/ora/candidates/register";
  static const String candidateLogin = "/api/ora/candidates/login";
  static const String candidateProfile = "/api/ora/candidates/profile";
  static const String candidateDashboard = "/api/ora/candidates/dashboard";
  static const String candidateUploadDocs = "/api/ora/candidates/upload-documents";
  static const String candidateSendOtp = "/api/ora/candidates/send-otp";
  static const String candidateVerifyOtp = "/api/ora/candidates/verify-otp";
  static const String candidateSendMobileOtp = "/api/ora/candidates/send-mobile-otp";
  static const String candidateVerifyMobileOtp = "/api/ora/candidates/verify-mobile-otp";

  // ORA Applications
  static const String advertisementsActive = "/api/ramm/advertisements"; // Assuming active jobs come from here
  static const String applicationForm = "/api/ora/applications/form";
  static const String applicationSubmit = "/api/ora/applications/submit";
  static const String myApplications = "/api/ora/applications";

  // ORA Payments
  static const String initiatePayment = "/api/ora/payments/initiate";
  static const String verifyPayment = "/api/ora/payments/verify-callback";
  static const String paymentHistory = "/api/ora/payments/history";
}
