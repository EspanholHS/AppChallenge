// lib/main.dart

import 'package:flutter/material.dart';
import 'pages/login_screen.dart';
import 'pages/inova_plus_page.dart';
import 'pages/submit_idea_page.dart';
import 'pages/qr_code_page.dart';
import 'pages/points_page.dart';
import 'pages/explore_page.dart';
import 'services/points_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sempre inicia com 280 a cada execução fria do app
  await PointsStorage.resetOnLaunch();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inova+ App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login':  (_) => const LoginScreen(),
        '/home':   (_) => const InovaPlusPage(),
        '/submit': (_) => const SubmitIdeaPage(),
        '/qr':     (_) => const QrCodePage(),
        '/points':(_) => const PointsPage(),
        '/explore':(_) => const ExplorePage(),
      },
    );
  }
}
