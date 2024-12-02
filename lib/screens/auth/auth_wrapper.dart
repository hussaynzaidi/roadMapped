import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import '../auth/login.dart';
import '../../services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (_, authService, __) {
        if (authService.currentUser != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
} 