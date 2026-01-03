import 'package:hyperlog/login_state.dart';
import 'package:hyperlog/theme/app_theme.dart';
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

  // Crashlytics is not supported on web
  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => LoginState(),
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
      home: Consumer<LoginState>(
        builder: (context, loginState, _) {
          return loginState.isLoggedIn
              ? const HomeScreen(title: "HYPERLOG")
              : const AuthScreen();
        },
      ),
    );
  }
}
