import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/calibration_screen.dart';
import 'screens/settings_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mpmtsfjpxueoqwseaykv.supabase.co',
    anonKey: 'sb_publishable_YOp0j0zGfjctR4Y8tpXpEQ_FAVdG2OA',
  );

  runApp(const PulseGuardApp());
}



class PulseGuardApp extends StatelessWidget {
  const PulseGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PulseGuard',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),

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