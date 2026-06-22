import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/permission_dialog.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideUp =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    _controller.forward();
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
      body: FadeTransition(
        opacity: _slideUp,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Top tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'PERMISSIONS',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Big icon
                SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(_slideUp),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white, size: 52),
                  ),
                ),
                const Spacer(),
                // Heading
                SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.2), end: Offset.zero)
                      .animate(_slideUp),
                  child: const Text(
                    'Stay\nAhead.',
                    style: TextStyle(
                      fontFamily: 'LibreBaskerville',
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                'Allow Trezo to access your camera to scan receipts, storage for recent photos, and send smart reminders.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 48),
              // Allow button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    await [
                      Permission.camera,
                      Permission.storage,
                      Permission.photos,
                      Permission.notification,
                      Permission.scheduleExactAlarm,
                    ].request();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_seen_onboarding', true);
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Allow Permissions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Skip
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    await showGlobalPermissionDialog(context);
                    
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_seen_onboarding', true);
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      ),

    );
  }
}
