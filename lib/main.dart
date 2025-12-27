import 'package:flutter/material.dart';
import 'package:corp_pulse/theme/app_theme.dart';
import 'package:corp_pulse/views/welcome_screen.dart';
import 'package:corp_pulse/views/login_screen.dart';
import 'package:corp_pulse/views/main_layout.dart';
import 'package:corp_pulse/views/region_detail_screen.dart';
import 'package:corp_pulse/models/data_models.dart';

void main() {
  runApp(const CorpPulseApp());
}

class CorpPulseApp extends StatelessWidget {
  const CorpPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NLPL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          case '/login':
            return _fadeRoute(const LoginScreen());
          case '/main':
            final session = settings.arguments as UserSession;
            return _fadeRoute(MainLayout(session: session));
          case '/region_detail':
            final row = settings.arguments as RegionReportRow;
            return MaterialPageRoute(builder: (_) => RegionDetailScreen(row: row));
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Route not found')),
              ),
            );
        }
      },
    );
  }

  PageRoute _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
