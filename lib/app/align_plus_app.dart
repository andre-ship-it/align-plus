import 'package:flutter/material.dart';

import 'main_app_flow.dart';
import 'theme.dart';

class AlignPlusApp extends StatelessWidget {
  const AlignPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildPremiumTheme(),
      home: const MainAppFlow(),
    );
  }
}
