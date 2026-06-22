import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../core/services/encryption_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _letterController;
  late Animation<double> _letterAnimation;

  @override
  void initState() {
    super.initState();

    _letterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _letterAnimation = CurvedAnimation(
      parent: _letterController,
      curve: Curves.easeOutExpo,
    );

    _letterController.forward();

    Future.delayed(const Duration(milliseconds: 2000), () async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_seen_onboarding') ?? false;
      
      // Initialize encryption service if we have a UID
      await EncryptionService.initialize();

      if (mounted) {
        if (hasSeen) {
          final isAppLockEnabled = await AuthService.isAppLockEnabled();
          if (isAppLockEnabled) {
            context.go('/lock');
          } else {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              context.go('/home');
            } else {
              context.go('/login');
            }
          }
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _letterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(_letterAnimation),
              child: FadeTransition(
                opacity: _letterAnimation,
                child: Image.asset(
                  'assets/images/splash.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

