import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'l10n/app_localizations.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/sos_service.dart';
import 'providers/location_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/emergency_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/safety_map_provider.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/sos/sos_screen.dart';
import 'screens/reports/reports_list_screen.dart';
import 'screens/reports/create_report_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/emergency_contacts_screen.dart';
import 'screens/legal/privacy_policy_screen.dart';
import 'screens/legal/terms_conditions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase init error (expected if config missing): $e');
  }

  // Initialize notification service (non-blocking)
  try {
    final notificationService = NotificationService();
    notificationService.initialize().catchError((e) {
      debugPrint('Notification service initialization failed: $e');
    });
  } catch (e) {
    debugPrint('Notification service creation failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        Provider(create: (_) => NotificationService()),

        // Providers
        ChangeNotifierProxyProvider<LocationService, LocationProvider>(
          create: (context) => LocationProvider(
            locationService: context.read<LocationService>(),
            notificationService: context.read<NotificationService>(),
          ),
          update: (context, locationService, previous) =>
              previous ??
              LocationProvider(
                locationService: locationService,
                notificationService: context.read<NotificationService>(),
              ),
        ),

        ChangeNotifierProvider(
          create: (context) => ReportsProvider(
            firestoreService: context.read<FirestoreService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) {
            final locationService = context.read<LocationService>();
            final notificationService = context.read<NotificationService>();
            final sosService = SOSService(
              locationService: locationService,
              notificationService: notificationService,
            );
            return EmergencyProvider(
              firestoreService: context.read<FirestoreService>(),
              sosService: sosService,
            );
          },
        ),

        ChangeNotifierProvider(create: (_) => SafetyMapProvider()),

        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Nigehbaan',
            theme: AppTheme.lightTheme,
            // localizationsDelegates: const [
            //   AppLocalizations.delegate,
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            //   GlobalCupertinoLocalizations.delegate,
            // ],
            // supportedLocales: const [
            //   Locale('en'),
            //   Locale('zh'),
            // ],
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.onboarding: (context) => const OnboardingScreen(),
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.signup: (context) => const SignupScreen(),
              AppRoutes.home: (context) => const HomeScreen(),
              AppRoutes.map: (context) => const MapScreen(),
              AppRoutes.sos: (context) => const SOSScreen(),
              AppRoutes.reports: (context) => const ReportsListScreen(),
              AppRoutes.createReport: (context) => const CreateReportScreen(),
              AppRoutes.settings: (context) => const SettingsScreen(),
              AppRoutes.emergencyContacts: (context) =>
                  const EmergencyContactsScreen(),
              AppRoutes.privacyPolicy: (context) => const PrivacyPolicyScreen(),
              AppRoutes.termsConditions: (context) =>
                  const TermsConditionsScreen(),
            },
          );
        },
      ),
    );
  }
}
