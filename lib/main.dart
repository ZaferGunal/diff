import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:untitled5/publicPages/FreeTrialHomePage.dart';
import 'TILFreePages/TILFreeDashboard.dart';
import 'BocconiPages/home_page.dart';

import 'BocconiPages/signup_page.dart';
import 'BocconiPages/welcome_page.dart';
import 'MainPages/Dashboard.dart';
import 'UserProvider.dart';
import 'formals/DSAgreement.dart';
import 'formals/PrivacyPolicy.dart';
import 'formals/Terms.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  final authProvider = AuthProvider();
  await authProvider.checkPreviousSession();

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const EducationPlatformApp(),
    ),
  );
}

class EducationPlatformApp extends StatefulWidget {
  const EducationPlatformApp({super.key});

  @override
  State<EducationPlatformApp> createState() => _EducationPlatformAppState();
}

class _EducationPlatformAppState extends State<EducationPlatformApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PractiCo',
      themeMode: _themeMode,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0f1419),
        primaryColor: const Color(0xFF0046ad),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0046ad),
          secondary: Color(0xFF324d3b),
          tertiary: Color(0xFF324159),
          surface: Color(0xFF1a1f2e),
          background: Color(0xFF0f1419),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFe8ecf1),
          onBackground: Color(0xFFe8ecf1),
        ),
        cardColor: const Color(0xFF1a1f2e),
        dividerColor: const Color(0xFF324159).withOpacity(0.3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0f1419),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFe8ecf1)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0046ad),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1a1f2e),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF324159)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF324159)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0046ad), width: 2),
          ),
        ),
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFf5f7fa),
        primaryColor: const Color(0xFF0046ad),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0046ad),
          secondary: Color(0xFF324d3b),
          tertiary: Color(0xFF324159),
          surface: Colors.white,
          background: Color(0xFFf5f7fa),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1a1f2e),
          onBackground: Color(0xFF1a1f2e),
        ),
        cardColor: Colors.white,
        dividerColor: const Color(0xFF324159).withOpacity(0.2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1a1f2e)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1a1f2e),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0046ad),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            elevation: 2,
            shadowColor: const Color(0xFF0046ad).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF324159)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF324159).withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0046ad), width: 2),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF324d3b),
        ),
      ),

      home: AuthGate(toggleTheme: toggleTheme),

      routes: {
        '/terms': (context) => TermsPage(),
        '/privacy': (context) => PrivacyPolicyPage(),
        '/distance_sales_agreement': (context) => DSAgreementPage(),
        '/app': (context) => AuthGate(toggleTheme: toggleTheme),
        '/free-trial': (context) => FreeTrialHomePage(toggleTheme: toggleTheme),
        '/signup': (context) => SignUpPage(toggleTheme: toggleTheme),
        '/tili': (context) => TILFreeDashboard(toggleTheme: toggleTheme),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '404',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Page not found'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/app'),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  final VoidCallback toggleTheme;

  const AuthGate({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, ({bool isAuth, String? token})>(
      selector: (_, authProvider) => (
      isAuth: authProvider.isAuthenticated,
      token: authProvider.token,
      ),
      builder: (context, authState, _) {
        if (authState.isAuth && authState.token != null) {
          return DashboardPage(
            toggleTheme: toggleTheme,
            token: authState.token!,
          );
        }
        return WelcomePage(toggleTheme: toggleTheme);
      },
    );
  }
}