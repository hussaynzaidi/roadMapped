import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import 'repositories/roadmap_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/progress_repository.dart';
import 'repositories/resource_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RoadMapped',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}
