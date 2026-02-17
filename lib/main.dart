import 'package:flutter/material.dart';
import 'app/main_app_flow.dart';

void main() {
  // Required for SharedPreferences and PWA initialization
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlignPlusApp());
}

class AlignPlusApp extends StatelessWidget {
  const AlignPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Align+ 30-Day Reset',
      debugShowCheckedModeBanner: false,
      
      // Branding: Premium, Authoritative, and Clinical
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008080), // FitWell Teal
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia', // Serif font for a professional/rehab feel
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      
      // Hands off control to the App Flow module
      home: const MainAppFlow(),
    );
  }
}
