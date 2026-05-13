import 'package:flutter/material.dart';
import 'theme/otr_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/registration_page.dart';
import 'screens/otp_verification_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/bio_page.dart';
import 'screens/address_page.dart';
import 'screens/documents_page.dart';
import 'screens/profile_detail_page.dart';
import 'screens/applied_recruitment_page.dart';
import 'screens/recruitment_detail_page.dart';
import 'screens/total_recruitment_page.dart';
import 'screens/apply_now_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/admit_card_page.dart';
import 'screens/payment_history_page.dart';
import 'screens/vendor_registration_page.dart';
import 'screens/vendor_dashboard_page.dart';
import 'screens/vendor_open_eois_page.dart';
import 'screens/vendor_my_bids_page.dart';
import 'screens/vendor_submit_proposal_page.dart';
import 'screens/vendor_profile_page.dart';
import 'screens/vendor_performance_page.dart';
import 'screens/vendor_work_orders_page.dart';
import 'models/eoi_model.dart';

void main() {
  runApp(const OtrModelApp());
}

class OtrModelApp extends StatelessWidget {
  const OtrModelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTR Model',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: OtrTheme.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: OtrTheme.primaryBlue,
          primary: OtrTheme.primaryBlue,
          secondary: OtrTheme.mediumBlue,
          surface: OtrTheme.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: OtrTheme.darkNavy,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: OtrTheme.darkNavy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: OtrTheme.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: OtrTheme.primaryBlue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          backgroundColor: const Color(0xFF1E293B), // Dark slate
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          actionTextColor: OtrTheme.primaryBlue,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/otp': (context) => const OtpVerificationPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/bio': (context) => const BioPage(),
        '/address': (context) => const AddressPage(),
        '/documents': (context) => const DocumentsPage(),
        '/status': (context) => const ProfileDetailPage(),
        '/applied-recruitment': (context) => const AppliedRecruitmentPage(),
        '/recruitment-detail': (context) => const RecruitmentDetailPage(),
        '/total-recruitment': (context) => const TotalRecruitmentPage(),
        '/apply-now': (context) => const ApplyNowPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/otp-verification': (context) => const OtpVerificationPage(),
        '/admit-card': (context) => const AdmitCardPage(),
        '/payment': (context) => const PaymentHistoryPage(),
        '/vendor-register': (context) => const VendorRegistrationPage(),
        '/vendor-dashboard': (context) => const VendorDashboardPage(),
        '/vendor-open-eois': (context) => const VendorOpenEoisPage(),
        '/vendor-my-bids': (context) => const VendorMyBidsPage(),
        '/vendor-submit-proposal': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as EoiModel;
          return VendorSubmitProposalPage(eoi: args);
        },
        '/vendor-profile': (context) => const VendorProfilePage(),
        '/vendor-performance': (context) => const VendorPerformancePage(),
        '/vendor-work-orders': (context) => const VendorWorkOrdersPage(),
      },
    );
  }
}
