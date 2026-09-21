import 'package:flutter/material.dart';
import 'package:gts/views/screens/download_screen.dart';
import 'package:gts/views/screens/home_screen.dart';
import 'package:gts/views/screens/onboarding_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    OnboardingScreen.routeName: (ctx) => OnboardingScreen(),
    DownloadScreen.routeName: (ctx) => DownloadScreen(),
    HomeScreen.routeName: (ctx) => HomeScreen(),
  };
}
