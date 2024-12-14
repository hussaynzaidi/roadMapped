import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import 'repositories/roadmap_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/progress_repository.dart';
import 'repositories/resource_repository.dart';
import 'services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await dotenv.load(fileName: ".env"); // Load environment variables
  } catch (e) {
    throw Exception('Error loading .env file: $e'); // Print error if any
  }
  Gemini.init(apiKey: dotenv.env['gemini_api_key'] ?? '');

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        Provider<RoadmapRepository>(
          create: (_) => RoadmapRepository(),
        ),
        Provider<ProgressRepository>(
          create: (_) => ProgressRepository(),
        ),
        Provider<ResourceRepository>(
          create: (_) => ResourceRepository(),
        ),
        ChangeNotifierProxyProvider<UserRepository, AuthService>(
          create: (context) => AuthService(context.read<UserRepository>()),
          update: (context, userRepository, previous) =>
              previous ?? AuthService(userRepository),
        ),
        Provider<SharedPreferences>.value(
          value: prefs,
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeService(
            context.read<SharedPreferences>(),
          ),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'RoadMapped',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
