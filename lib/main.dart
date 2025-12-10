import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled5/AddTestPage.dart';
import 'UserProvider.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();

  // Eski oturumu kontrol et
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
        scaffoldBackgroundColor: const Color(0xFF0f1419), // Daha derin siyah-lacivert
        primaryColor: const Color(0xFF0046ad), // Bocco Blue
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0046ad), // Bocco Blue
          secondary: Color(0xFF324d3b), // Green Dark
          tertiary: Color(0xFF324159), // Grey
          surface: Color(0xFF1a1f2e), // Card/Surface rengi
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
        scaffoldBackgroundColor: const Color(0xFFf5f7fa), // Hafif gri-beyaz
        primaryColor: const Color(0xFF0046ad), // Bocco Blue
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0046ad), // Bocco Blue
          secondary: Color(0xFF324d3b), // Green Dark
          tertiary: Color(0xFF324159), // Grey
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
          backgroundColor: Color(0xFF324d3b), // Green Dark accent
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated && authProvider.token != null) {
            return HomePage(
              toggleTheme: toggleTheme,
              token: authProvider.token!,
            );
          }
          return    WelcomePage(toggleTheme: toggleTheme);
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}