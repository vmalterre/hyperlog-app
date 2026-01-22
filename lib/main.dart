import 'package:hyperlog/config/app_config.dart';
import 'package:hyperlog/database/database_provider.dart';
import 'package:hyperlog/session_state.dart';
import 'package:hyperlog/services/preferences_service.dart';
import 'package:hyperlog/services/screen_config_service.dart';
import 'package:hyperlog/theme/app_theme.dart';
import 'package:hyperlog/widgets/environment_banner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyperlog/screens/auth_screen.dart';
import 'package:hyperlog/screens/home_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment config from --dart-define
  // Run with: flutter run --dart-define=ENV=prod for production
  // Accepts both ENV and ENVIRONMENT for flexibility
  const envShort = String.fromEnvironment('ENV', defaultValue: '');
  const envLong = String.fromEnvironment('ENVIRONMENT', defaultValue: '');
  final env = envShort.isNotEmpty ? envShort : (envLong.isNotEmpty ? envLong : 'dev');
  AppConfig.initialize(environment: env);

  // Always log environment at startup to catch misconfiguration
  debugPrint('====================================');
  debugPrint('HyperLog ${AppConfig.current.appName}');
  debugPrint('Environment: ${AppConfig.current.environment.name.toUpperCase()}');
  debugPrint('API: ${AppConfig.apiBaseUrl}');
  debugPrint('====================================');

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF242526),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize preferences for local storage
  await PreferencesService.instance.init();

  // Initialize screen config service
  await ScreenConfigService.instance.init();

  // Initialize local database and repositories (for offline-first)
  await DatabaseProvider.instance.initialize();

  // Crashlytics is not supported on web
  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  // Create session state and initialize before running app
  final sessionState = SessionState();
  await sessionState.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: sessionState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        // Wrap ALL routes with EnvironmentBanner so it appears on every screen
        return EnvironmentBanner(child: child ?? const SizedBox.shrink());
      },
      home: Consumer<SessionState>(
        builder: (context, session, _) {
          // Show loading while session initializes
          if (!session.isInitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return session.isLoggedIn
              ? const HomeScreen(title: "HYPERLOG")
              : const AuthScreen();
        },
      ),
    );
  }
}
