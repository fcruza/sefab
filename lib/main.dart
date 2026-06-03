import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/data_provider.dart';
import 'features/auth/login_page.dart';
import 'features/modules/modules_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(api)..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => DataProvider(api),
        ),
      ],
      child: const SefabApp(),
    ),
  );
}

class SefabApp extends StatelessWidget {
  const SefabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB52A23),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          if (auth.isRestoringSession) {
            return const SplashAuthPage();
          }

          return auth.isLoggedIn
              ? const ModulesPage()
              : const LoginPage();
        },
      ),
    );
  }
}

class SplashAuthPage extends StatelessWidget {
  const SplashAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1F2937),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF97316),
        ),
      ),
    );
  }
}