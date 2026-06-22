import 'package:flutter/material.dart';

/// Represents a single extracted entity with display metadata.
class EntityResult {
  final String text;
  final String type;
  final String? detail;
  final IconData icon;
  final Color color;

  const EntityResult({
    required this.text,
    required this.type,
    this.detail,
    required this.icon,
    required this.color,
  });
}
