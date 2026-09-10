import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../../features/onboarding/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/profile/presentation/screens/complete_profile_screen.dart';
import '../../features/profile/presentation/screens/add_family_member_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/doctor/presentation/screens/doctor_home_screen.dart';
import '../../features/assessment/presentation/screens/medical_profile_flag_screen.dart';
import '../../features/assessment/presentation/screens/ayush_mode_screen.dart';
import '../../features/assessment/presentation/screens/dashvidha_pariksha_screen.dart';
import '../../features/assessment/presentation/screens/prakriti_screen.dart';
import '../../features/assessment/presentation/screens/vikriti_sara_screen.dart';
import '../../features/complaints/presentation/screens/present_complaint_screen.dart';
import '../../features/complaints/presentation/screens/family_history_screen.dart';
import '../../features/ai_summary/presentation/screens/ai_summary_screen.dart';
import '../../features/doctor/presentation/screens/doctor_homepage_screen.dart';
import '../../features/doctor/presentation/screens/patient_list_screen.dart';
import '../../features/doctor/presentation/screens/ai_patient_doc_screen.dart';

class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.languageSelection: (context) => const LanguageSelectionScreen(),
        AppRoutes.roleSelection: (context) => const RoleSelectionScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.otp: (context) => const OtpScreen(),
        AppRoutes.completeProfile: (context) => const CompleteProfileScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.addFamilyMember: (context) => const AddFamilyMemberScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.doctorHome: (context) => const DoctorHomepageScreen(),
        AppRoutes.doctorHomepage: (context) => const DoctorHomepageScreen(),
        AppRoutes.patientList: (context) => const PatientListScreen(),
        AppRoutes.aiPatientDoc: (context) => const AiPatientDocScreen(),
        AppRoutes.startAssessment: (context) => const MedicalProfileFlagScreen(),
        AppRoutes.medicalProfileFlag: (context) => const MedicalProfileFlagScreen(),
        AppRoutes.ayushMode: (context) => const AyushModeScreen(),
        AppRoutes.dashvidhaPariksha: (context) => const DashvidhaParikshaScreen(),
        AppRoutes.prakriti: (context) => const PrakritiScreen(),
        AppRoutes.vikritiSara: (context) => const VikritiSaraScreen(),
        AppRoutes.presentComplaint: (context) => const PresentComplaintScreen(),
        AppRoutes.familyHistory: (context) => const FamilyHistoryScreen(),
        AppRoutes.aiSummary: (context) => const AiSummaryScreen(),
      };
}
