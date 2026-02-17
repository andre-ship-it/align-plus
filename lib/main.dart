import 'package:flutter/material.dart';
import 'app/main_app_flow.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlignPlusApp());
}

class AlignPlusApp extends StatelessWidget {
  const AlignPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitWell Align+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF008080), // FitWell Teal
        fontFamily: 'Georgia', // Authoritative serif
      ),
      home: const MainAppFlow(),
    );
  }
}
