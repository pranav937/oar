class ApiConstants {
  static const String baseUrl = "http://192.168.1.3:3000"; // Updated local API URL

  // ORA Candidate Endpoints++
  static const String candidateRegister = "/api/ora/candidates/register";
  static const String candidateLogin = "/api/ora/candidates/login";
  static const String candidateProfile = "/api/ora/candidates/profile";
  static const String candidateDashboard = "/api/ora/candidates/dashboard";
  static const String candidateUploadPhoto = "/api/ora/candidates/upload-photo";
  static const String candidateUploadSignature = "/api/ora/candidates/upload-signature";
  static const String candidateUploadDocs = "/api/ora/candidates/documents";
  static const String candidateDeletePhoto = "/api/ora/candidates/photo";
  static const String candidateDeleteSignature = "/api/ora/candidates/signature";
  static const String candidateSendOtp = "/api/ora/candidates/send-otp";
  static const String candidateVerifyOtp = "/api/ora/candidates/verify-otp";
  static const String candidateSendMobileOtp = "/api/ora/candidates/send-mobile-otp";
  static const String candidateVerifyMobileOtp = "/api/ora/candidates/verify-mobile-otp";
  static const String candidateForgotPassword = "/api/ora/candidates/forgot-password";
  static const String candidateResetPassword = "/api/ora/candidates/reset-password";

  // ORA Applications
  static const String advertisementsActive = "/api/ramm/advertisements"; // Assuming active jobs come from here
  static const String applicationForm = "/api/ora/applications/form";
  static const String applicationSubmit = "/api/ora/applications/submit";
  static const String myApplications = "/api/ora/applications";
  static const String examCentres = "/api/ora/exam-centres";

  // ORA Payments
  static const String initiatePayment = "/api/ora/payments/initiate";
  static const String verifyPayment = "/api/ora/payments/verify-callback";
  static const String paymentHistory = "/api/ora/payments/history";
  static const String admitCardFetch = "/api/ora/admit-cards";
}
