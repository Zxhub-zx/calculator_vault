import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';
import 'screens/setup_pin_screen.dart';
import 'services/security_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configured = await SecurityService().isConfigured();
  runApp(CalculatorVaultApp(configured: configured));
}

class CalculatorVaultApp extends StatelessWidget {
  final bool configured;
  const CalculatorVaultApp({super.key, required this.configured});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE9E9E9),
          surface: Color(0xFF171717),
        ),
      ),
      home: configured ? const CalculatorScreen() : const SetupPinScreen(),
    );
  }
}
