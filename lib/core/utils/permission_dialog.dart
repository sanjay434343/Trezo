import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> showGlobalPermissionDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Permissions Required',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Trezo requires Camera, Storage, and Notification permissions to scan receipts and send warranty reminders. Please grant them to continue.',
          style: TextStyle(color: Colors.white.withAlpha(180)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Not Now',
              style: TextStyle(color: Colors.white.withAlpha(128)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final statuses = await [
                Permission.camera,
                Permission.storage,
                Permission.photos,
                Permission.notification,
                Permission.scheduleExactAlarm,
              ].request();
              
              bool allGranted = true;
              statuses.forEach((key, value) {
                if (key == Permission.storage && value.isPermanentlyDenied) {
                  // On Android 13+, storage is often permanently denied. We rely on photos.
                } else if (!value.isGranted && !value.isLimited && key != Permission.storage) {
                  allGranted = false;
                }
              });

              if (!allGranted) {
                await openAppSettings();
              }
              
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text(
              'Grant Permissions',
              style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
