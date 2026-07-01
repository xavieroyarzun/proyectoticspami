import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/calibration_screen.dart';
import 'screens/settings_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'services/app_data.dart';
import 'services/sensor_repository.dart';
import 'services/alert_service.dart';
final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mpmtsfjpxueoqwseaykv.supabase.co',
    anonKey: 'sb_publishable_YOp0j0zGfjctR4Y8tpXpEQ_FAVdG2OA',
  );
  bluetoothService.connect();
  SensorRepository().startSync();
  AlertService(navigatorKey).start();
  runApp(const PulseGuardApp());
}



class PulseGuardApp extends StatelessWidget {
  const PulseGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'PulseGuard',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: const LoginScreen(),

      routes: {
        '/home': (context) => const HomeScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/calibration': (context) => const CalibrationScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/stats': (context) => const StatisticsScreen(),
      },
    );
  }
}