import 'package:flutter/material.dart';
import 'package:gts/core/constants/named_routes.dart';
import 'package:gts/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'services/navigation_services.dart';
import 'views/screens/onboarding_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: const GTSApp(),
    ),
  );
}

class GTSApp extends StatelessWidget {
  const GTSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Get That Song',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      routes: AppRoutes.routes,
      home: const OnboardingScreen(),
    );
  }
}
