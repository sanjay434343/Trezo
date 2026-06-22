import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/database_service.dart';
import 'core/services/reminder_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/logger_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // ── Initialize Firebase ───────────────────────────────────────────────────
  await Firebase.initializeApp();

  // ── Initialize Isar database ──────────────────────────────────────────────
  await DatabaseService.initialize();

  LoggerService.i('App Initialized successfully.');

  // ── Initialize Reminder Service (Notifications & Exact Alarms) ──────────────
  await ReminderService.initialize();

  // ── Sync all reminders & start daily cleanup worker ───────────────────────
  // Runs in the background after the first frame so the UI isn't blocked.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await ReminderService.syncAllReminders();
  });

  runApp(
    const ProviderScope(
      child: TrezoApp(),
    ),
  );
}

class TrezoApp extends StatelessWidget {
  const TrezoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: MaterialApp.router(
        title: 'Trezo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
