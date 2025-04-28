import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../providers/auth_provider.dart';
import '../splash_screen.dart';
import '../main_screen.dart';
import '../welcome_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    // Utiliser Future.microtask pour éviter le setState pendant le build
    Future.microtask(() => _checkAuthStatus());
  }

  Future<void> _checkAuthStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();

      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    } catch (e) {
      developer.log(
          'Erreur lors de la vérification du statut d\'authentification: $e',
          name: 'AuthWrapper');
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const SplashScreen();
    }

    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return const MainScreen();
    } else {
      return const WelcomeScreen();
    }
  }
}
