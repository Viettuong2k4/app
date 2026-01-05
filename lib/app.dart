import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songkhoe/providers/dashboard_provider.dart';
import 'package:songkhoe/providers/health_provider.dart';
import 'package:songkhoe/providers/medicine_provider.dart';
import 'package:songkhoe/screens/auth/forgot_password_screen.dart';
import 'package:songkhoe/screens/health/add_health_screen.dart';
import 'package:songkhoe/screens/health/health_detail_screen.dart';
import 'package:songkhoe/screens/health/health_reminders_screen.dart';
import 'package:songkhoe/screens/health/schedule_health_measurement_screen.dart'; // Import màn hình mới
import 'package:songkhoe/screens/medicine/add_medicine_screen.dart';
import 'package:songkhoe/screens/medicine/medicine_detail_screen.dart';
import 'package:songkhoe/screens/profile/notification_settings_screen.dart';
import 'package:songkhoe/screens/profile/profile_setup_screen.dart';

import 'core/theme/app_colors.dart';

import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_layout/main_layout_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),

        ChangeNotifierProxyProvider2<
          HealthProvider,
          MedicineProvider,
          DashboardProvider
        >(
          create: (context) => DashboardProvider(
            Provider.of<HealthProvider>(context, listen: false),
            Provider.of<MedicineProvider>(context, listen: false),
          ),
          update: (context, health, medicine, previous) =>
              DashboardProvider(health, medicine),
        ),
      ],
      child: MaterialApp(
        title: 'Sức Khỏe Plus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: AppColors.gray50,
          primaryColor: AppColors.blue500,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.blue500,
            primary: AppColors.blue500,
            secondary: AppColors.blue600,
            background: AppColors.gray50,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.gray700),
            titleTextStyle: TextStyle(
              color: AppColors.gray900,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        initialRoute: '/',

        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainLayoutScreen(),
          '/health-detail': (context) => const HealthDetailScreen(),
          '/medicine-detail': (context) => const MedicineDetailScreen(),
          '/add-health': (context) => const AddHealthScreen(),
          '/schedule-health': (context) =>
              const ScheduleHealthMeasurementScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/notification-settings': (context) =>
              const NotificationSettingsScreen(),
          '/add-medicine': (context) => const AddMedicineScreen(),
          '/profile-setup': (context) => const ProfileSetupScreen(),
          '/health-reminders': (context) => const HealthRemindersScreen(),
          '/add-health-schedule': (context) =>
              const ScheduleHealthMeasurementScreen(),
        },
      ),
    );
  }
}
