import 'package:flutter/material.dart';
import 'modules/common/role_selection_screen.dart';
import 'modules/common/language_selection_screen.dart';
import 'modules/patient/auth/login_screen.dart';
import 'modules/patient/auth/otp_screen.dart';
import 'modules/patient/home/patient_home_screen.dart';
import 'modules/asha/auth/asha_login_screen.dart';
import 'modules/asha/auth/asha_pin_login_screen.dart';
import 'modules/asha/home/asha_home_screen.dart';
import 'modules/common/consent_screen.dart';
import 'modules/supervisor/home/supervisor_dashboard_screen.dart';
import 'modules/caregiver/home/caregiver_home_screen.dart';
import 'modules/asha/incentives/incentive_tracker_screen.dart';
import 'app_state.dart';
import 'modules/patient/home/medicine_store.dart';
import 'package:provider/provider.dart';
import 'core/database/local_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDb.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppState.instance),
        ChangeNotifierProvider.value(value: MedicineStore.instance),
      ],
      child: const MaternalHealthApp(),
    ),
  );
}

class MaternalHealthApp extends StatelessWidget {
  const MaternalHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp(
          title: 'Maternal Health',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0077B6),
              primary: const Color(0xFF0077B6),
              secondary: const Color(0xFF00B4D8),
              tertiary: const Color(0xFFCAF0F8),
              surface: const Color(0xFFF8F9FA),
            ),
            textTheme: const TextTheme(
              headlineMedium: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
              bodyLarge: TextStyle(
                color: Color(0xFF6D6D6D),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8B94),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFFF8B94), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
          initialRoute: '/language',
          routes: {
            '/language': (context) => const LanguageSelectionScreen(),
            '/consent': (context) => const ConsentScreen(),
            '/selection': (context) => const RoleSelectionScreen(),
            '/login': (context) => const LoginScreen(),
            '/otp': (context) => const OtpScreen(),
            '/patient_home': (context) => const PatientHomeScreen(),
            '/asha_login': (context) => const AshaLoginScreen(),
            '/asha_pin_login': (context) => const AshaPinLoginScreen(),
            '/asha_home': (context) => const AshaHomeScreen(),
            '/incentive_tracker': (context) => const IncentiveTrackerScreen(),
            '/supervisor_home': (context) => const SupervisorDashboardScreen(),
            '/caregiver_home': (context) => const CaregiverHomeScreen(),
          },
        );
      },
    );
  }
}
