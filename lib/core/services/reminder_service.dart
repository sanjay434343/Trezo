import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trezo/core/models/asset.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'database_service.dart';

/// Dart-side engine for Exact Alarms and Push Notifications.
class ReminderService {
  ReminderService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// The fixed list of "days before expiry" at which we send a reminder.
  static const reminderDays = [10, 7, 1];

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  /// Request permissions for Android 13+ (POST_NOTIFICATIONS) and Exact Alarms
  static Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  static Future<void> scheduleRemindersForAsset(Asset asset) async {
    if (asset.endDate == null) return;

    final now = DateTime.now();
    for (final daysBefore in reminderDays) {
      if (asset.reminderSentDays.contains(daysBefore)) continue;

      final fireAt = asset.endDate!.subtract(Duration(days: daysBefore));
      if (fireAt.isBefore(now)) continue;

      final notificationId = _generateId(asset.id, daysBefore);
      final title = _getTitle(daysBefore);
      final body = '${asset.name} warranty expires in $daysBefore days';

      await _scheduleNotification(notificationId, title, body, fireAt);
    }
  }

  static Future<void> scheduleCustomReminderForAsset(Asset asset) async {
    if (!asset.customReminderEnabled || asset.customReminderDate == null) {
      await cancelReminder(asset.id, -1);
      return;
    }

    final now = DateTime.now();
    final fireAt = asset.customReminderDate!;
    if (fireAt.isBefore(now)) return;

    final notificationId = _generateId(asset.id, -1);
    await _scheduleNotification(
      notificationId,
      '⏰ Custom Reminder',
      'You have a custom reminder for ${asset.name}',
      fireAt,
    );
  }

  static Future<void> cancelRemindersForAsset(int assetId) async {
    for (final daysBefore in reminderDays) {
      await cancelReminder(assetId, daysBefore);
    }
    await cancelReminder(assetId, -1); // custom
    debugPrint('[ReminderService] Cancelled all reminders for asset $assetId');
  }

  static Future<void> cancelReminder(int assetId, int daysBefore) async {
    final notificationId = _generateId(assetId, daysBefore);
    await _notificationsPlugin.cancel(id: notificationId);
  }

  static Future<void> syncAllReminders() async {
    try {
      final assets = await DatabaseService.getAllAssets();
      final now = DateTime.now();

      int scheduled = 0;
      for (final asset in assets) {
        if (asset.endDate == null) continue;
        if (asset.endDate!.isBefore(now)) continue;

        await scheduleRemindersForAsset(asset);
        if (asset.customReminderEnabled) {
          await scheduleCustomReminderForAsset(asset);
        }
        scheduled++;
      }
      debugPrint('[ReminderService] Synced exact alarms for $scheduled assets');

      // Also clean up expired assets
      final count = await DatabaseService.cleanupExpiredAssets();
      if (count > 0) {
        debugPrint('[ReminderService] Cleaned up $count expired assets');
      }
    } catch (e) {
      debugPrint('[ReminderService] syncAllReminders error: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduleTime,
  ) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'trezo_reminders',
            'Expiry Reminders',
            channelDescription: 'Notifications for upcoming asset/warranty expirations',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('[ReminderService] Scheduled notification ID $id at $scheduleTime');
    } catch (e) {
      debugPrint('[ReminderService] Error scheduling $id: $e');
    }
  }

  static int _generateId(int assetId, int daysBefore) {
    // Generate a unique integer ID based on assetId and daysBefore
    return (assetId * 100) + (daysBefore > 0 ? daysBefore : 99);
  }

  static String _getTitle(int daysBefore) {
    if (daysBefore == 1) return 'Expires Tomorrow';
    if (daysBefore == 7) return 'Expires in 1 Week';
    return 'Expires in $daysBefore Days';
  }


}
