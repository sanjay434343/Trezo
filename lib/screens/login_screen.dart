import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/services/auth_service.dart';
import '../core/services/encryption_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    _controller.forward();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Back / logo row
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.inventory_2_rounded,
                        color: Colors.white.withValues(alpha: 0.7), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              // Heading
              SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 0.3), end: Offset.zero)
                    .animate(_anim),
                child: FadeTransition(
                  opacity: _anim,
                  child: const Text(
                    'Sign\nIn.',
                    style: TextStyle(
                      fontFamily: 'LibreBaskerville',
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _anim,
                child: Text(
                  'Access your personal asset vault.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 15,
                  ),
                ),
              ),
              const Spacer(),
              // Google sign in placeholder
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          final userCred = await AuthService.signInWithGoogle();
                          if (userCred != null) {
                            await EncryptionService.initialize();
                            if (context.mounted) {
                              context.go('/home');
                            }
                          } else {
                            if (context.mounted) {
                              setState(() => _isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Sign-in failed or cancelled.')),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF000000),
                    disabledBackgroundColor: Colors.white, // Keep white even when disabled
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF000000)),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/glogo.png', height: 24, width: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
