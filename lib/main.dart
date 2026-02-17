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
      title: 'Align+ 30-Day Reset',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008080),
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainAppFlow(),
    );
  }
}
