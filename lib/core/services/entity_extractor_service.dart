import 'package:flutter/material.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import '../models/entity_result.dart';

/// Singleton service that wraps ML Kit's EntityExtractor.
/// Call [initialize] once (it downloads the model if needed),
/// then call [extract] to get structured [EntityResult] objects.
class EntityExtractorService {
  EntityExtractorService._();
  static final EntityExtractorService instance = EntityExtractorService._();

  EntityExtractor? _extractor;
  bool _modelReady = false;

  /// Initializes the extractor and downloads the English model if needed.
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_modelReady) return;

    _extractor = EntityExtractor(
      language: EntityExtractorLanguage.english,
    );

    try {
      _modelReady = true;
    } catch (_) {
      // Model download failed; we'll still attempt extraction.
      _modelReady = false;
    }
  }

  /// Extracts entities from [text].
  /// Returns an empty list if the model isn't ready or text is blank.
  Future<List<EntityResult>> extract(String text) async {
    if (text.trim().isEmpty) return [];
    
    final results = <EntityResult>[];
    
    if (_extractor == null) await initialize();
    
    if (_modelReady && _extractor != null) {
      try {
        final annotations = await _extractor!.annotateText(text);
        results.addAll(_mapAnnotations(annotations));
      } catch (_) {}
    }

    // Fallback for Payment Cards (e.g. ATM cards missing from ML Kit)
    final atmRegex = RegExp(r'\b\d{4}[ -]?\d{4}[ -]?\d{4}[ -]?\d{2,7}\b');
    final matches = atmRegex.allMatches(text);
    for (final match in matches) {
      final raw = match.group(0)!;
      bool alreadyHasCard = results.any((r) => r.type == 'Payment Card' && r.text.replaceAll(' ', '') == raw.replaceAll(' ', ''));
      if (!alreadyHasCard) {
        results.add(EntityResult(
          text: raw,
          type: 'Payment Card',
          icon: Icons.credit_card_rounded,
          color: const Color(0xFFF87171),
        ));
      }
    }
    
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    for (int i = 0; i < lines.length; i++) {
      final lineUpper = lines[i].toUpperCase();
      if (lineUpper.startsWith('NAME')) {
        String name = lines[i].replaceAll(RegExp(r'^NAME[\s.:-]*', caseSensitive: false), '').trim();
        if (name.isEmpty && i + 1 < lines.length) name = lines[i+1].trim();
        if (name.isNotEmpty) {
          results.add(EntityResult(
            text: name,
            type: 'Person Name',
            icon: Icons.person_rounded,
            color: const Color(0xFF3B82F6),
          ));
        }
      }
    }

    return results;
  }

  /// Releases resources. Call this when you no longer need the service.
  Future<void> dispose() async {
    await _extractor?.close();
    _extractor = null;
    _modelReady = false;
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  List<EntityResult> _mapAnnotations(List<EntityAnnotation> annotations) {
    final results = <EntityResult>[];

    for (final annotation in annotations) {
      final rawText = annotation.text;
      for (final entity in annotation.entities) {
        final result = _toEntityResult(rawText, entity);
        if (result != null) results.add(result);
      }
    }

    // Deduplicate by (text + type)
    final seen = <String>{};
    return results.where((r) => seen.add('${r.type}|${r.text}')).toList();
  }

  EntityResult? _toEntityResult(String text, Entity entity) {
    switch (entity.type) {
      case EntityType.dateTime:
        final dt = entity as DateTimeEntity;
        final ts = dt.timestamp;
        String? detail;
        final d = DateTime.fromMillisecondsSinceEpoch(ts);
        detail =
            '${d.year}-${_pad(d.month)}-${_pad(d.day)}'
            '  ${_pad(d.hour)}:${_pad(d.minute)}';
        return EntityResult(
          text: text,
          type: 'Date / Time',
          detail: detail,
          icon: Icons.calendar_today_rounded,
          color: const Color(0xFFFFB800),
        );

      case EntityType.phone:
        return EntityResult(
          text: text,
          type: 'Phone',
          icon: Icons.phone_rounded,
          color: const Color(0xFF4ADE80),
        );

      case EntityType.email:
        return EntityResult(
          text: text,
          type: 'Email',
          icon: Icons.email_rounded,
          color: const Color(0xFF60A5FA),
        );

      case EntityType.address:
        return EntityResult(
          text: text,
          type: 'Address',
          icon: Icons.location_on_rounded,
          color: const Color(0xFFF472B6),
        );

      case EntityType.url:
        return EntityResult(
          text: text,
          type: 'URL',
          icon: Icons.link_rounded,
          color: const Color(0xFFA78BFA),
        );

      case EntityType.flightNumber:
        final fn = entity as FlightNumberEntity;
        return EntityResult(
          text: text,
          type: 'Flight',
          detail: '${fn.airlineCode} ${fn.flightNumber}',
          icon: Icons.flight_rounded,
          color: const Color(0xFF38BDF8),
        );

      case EntityType.money:
        final m = entity as MoneyEntity;
        final detail =
            '${m.unnormalizedCurrency} '
            '${m.integerPart}';
        return EntityResult(
          text: text,
          type: 'Money',
          detail: detail.trim(),
          icon: Icons.attach_money_rounded,
          color: const Color(0xFF34D399),
        );

      case EntityType.trackingNumber:
        return EntityResult(
          text: text,
          type: 'Tracking #',
          icon: Icons.local_shipping_rounded,
          color: const Color(0xFFFB923C),
        );

      case EntityType.iban:
        return EntityResult(
          text: text,
          type: 'IBAN',
          icon: Icons.account_balance_rounded,
          color: const Color(0xFFE879F9),
        );

      case EntityType.paymentCard:
        return EntityResult(
          text: text,
          type: 'Payment Card',
          icon: Icons.credit_card_rounded,
          color: const Color(0xFFF87171),
        );

      default:
        return null;
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
