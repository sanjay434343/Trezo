import '../models/entity_result.dart';

/// Structured result produced by [ScanContentParser] from OCR text + entities.
class ScanResult {
  /// Extracted document title (first prominent text line).
  final String? documentName;

  /// The earliest date found that is in the past (purchase / issue date).
  final DateTime? startDate;

  /// The latest date found that is in the future (expiry / warranty end).
  final DateTime? endDate;

  /// Extracted price (from Money entities).
  final double? price;

  /// Extracted serial / tracking number.
  final String? serial;

  /// Full raw OCR text.
  final String fullText;

  /// Whether [endDate] is in the past (already expired).
  final bool isExpired;

  /// Days until [endDate]. Negative when past expiry. `null` if no endDate.
  final int? daysUntilExpiry;

  const ScanResult({
    this.documentName,
    this.startDate,
    this.endDate,
    this.price,
    this.serial,
    required this.fullText,
    this.isExpired = false,
    this.daysUntilExpiry,
  });
}

/// Parses recognised text and extracted entities into a structured
/// [ScanResult], intelligently classifying dates as past/future and
/// extracting a document name.
class ScanContentParser {
  ScanContentParser._();

  // ── Noise words to skip when detecting a document title ─────────────────
  static final _noisePatterns = RegExp(
    r'^(invoice|receipt|bill|total|subtotal|tax|amount|date|no\.?|number|'
    r'qty|quantity|item|description|price|discount|paid|due|balance|'
    r'thank you|thanks|page|ref|reference)$',
    caseSensitive: false,
  );

  // ── Date keywords that help classify a date as start or end ─────────────
  static final _startKeywords = RegExp(
    r'(purchas|bought|issued?|order|invoice\s*date|billing|transaction|paid|'
    r'date\s*of\s*purchase)',
    caseSensitive: false,
  );
  static final _endKeywords = RegExp(
    r'(expir|warranty|valid\s*until|valid\s*thru|valid\s*through|'
    r'best\s*before|use\s*by|end\s*date|due\s*date|renewal|coverage\s*end)',
    caseSensitive: false,
  );

  /// Main entry point.
  ///
  /// * [recognizedText] — full OCR string.
  /// * [entities] — list of [EntityResult] from ML Kit Entity Extraction.
  static ScanResult parse(
    String recognizedText,
    List<EntityResult> entities,
  ) {
    // ── 1. Extract candidate dates ───────────────────────────────────────
    final datePairs = _extractDates(recognizedText, entities);
    final DateTime? startDate = datePairs.$1;
    final DateTime? endDate = datePairs.$2;

    // ── 2. Extract document name ────────────────────────────────────────
    final documentName = _extractDocumentName(recognizedText);

    // ── 3. Extract price ────────────────────────────────────────────────
    final price = _extractPrice(entities);

    // ── 4. Extract serial / tracking ────────────────────────────────────
    final serial = _extractSerial(entities);

    // ── 5. Classify past/future ─────────────────────────────────────────
    final now = DateTime.now();
    final bool isExpired = endDate != null && endDate.isBefore(now);
    final int? daysUntilExpiry =
        endDate != null ? endDate.difference(now).inDays : null;

    return ScanResult(
      documentName: documentName,
      startDate: startDate,
      endDate: endDate,
      price: price,
      serial: serial,
      fullText: recognizedText,
      isExpired: isExpired,
      daysUntilExpiry: daysUntilExpiry,
    );
  }

  // ── Date extraction & classification ──────────────────────────────────────

  /// Returns `(startDate, endDate)`.
  ///
  /// Classification strategy:
  /// 1. Check context around each date for start/end keywords.
  /// 2. If no keywords, dates in the past → startDate, future → endDate.
  /// 3. If only one date, use keyword context or default to startDate if past,
  ///    endDate if future.
  static (DateTime?, DateTime?) _extractDates(
    String text,
    List<EntityResult> entities,
  ) {
    final dateEntities =
        entities.where((e) => e.type == 'Date / Time').toList();

    if (dateEntities.isEmpty) return (null, null);

    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    // Parse all dates from entity details (format: "YYYY-MM-DD  HH:MM")
    final List<_ParsedDate> parsed = [];
    for (final entity in dateEntities) {
      final dt = _parseEntityDate(entity);
      if (dt == null) continue;

      // Determine context hint from surrounding text
      _DateHint hint = _DateHint.unknown;
      final entityIndex = text.indexOf(entity.text);
      if (entityIndex >= 0) {
        // Look at ±80 chars around the entity for context keywords
        final windowStart = (entityIndex - 80).clamp(0, text.length);
        final windowEnd = (entityIndex + entity.text.length + 80)
            .clamp(0, text.length);
        final context = text.substring(windowStart, windowEnd);

        if (_endKeywords.hasMatch(context)) {
          hint = _DateHint.end;
        } else if (_startKeywords.hasMatch(context)) {
          hint = _DateHint.start;
        }
      }

      parsed.add(_ParsedDate(dt, hint));
    }

    if (parsed.isEmpty) return (null, null);

    // Sort chronologically
    parsed.sort((a, b) => a.date.compareTo(b.date));

    if (parsed.length == 1) {
      final single = parsed.first;
      if (single.hint == _DateHint.end) {
        endDate = single.date;
      } else if (single.hint == _DateHint.start) {
        startDate = single.date;
      } else {
        // Default: past → start, future → end
        if (single.date.isBefore(now)) {
          startDate = single.date;
        } else {
          endDate = single.date;
        }
      }
    } else {
      // Multiple dates — assign by hint first, then by chronology
      for (final p in parsed) {
        if (p.hint == _DateHint.start && startDate == null) {
          startDate = p.date;
        } else if (p.hint == _DateHint.end && endDate == null) {
          endDate = p.date;
        }
      }

      // Fill remaining slots: earliest past → startDate, latest future → endDate
      if (startDate == null) {
        final pastDates =
            parsed.where((p) => p.date.isBefore(now)).toList();
        if (pastDates.isNotEmpty) {
          startDate = pastDates.first.date; // earliest past
        }
      }
      if (endDate == null) {
        final futureDates =
            parsed.where((p) => p.date.isAfter(now)).toList();
        if (futureDates.isNotEmpty) {
          endDate = futureDates.last.date; // latest future
        }
      }

      // Fallback: if we still only have one, use chronological order
      if (startDate == null && endDate == null) {
        startDate = parsed.first.date;
        if (parsed.length > 1) endDate = parsed.last.date;
      }
    }

    return (startDate, endDate);
  }

  /// Parse the detail string of a Date/Time entity ("YYYY-MM-DD  HH:MM")
  /// into a DateTime.
  static DateTime? _parseEntityDate(EntityResult entity) {
    final detail = entity.detail;
    if (detail == null || detail.length < 10) return null;
    // Detail format: "2025-06-15  09:30"
    final datePart = detail.substring(0, 10); // "2025-06-15"
    return DateTime.tryParse(datePart);
  }

  // ── Document name extraction ──────────────────────────────────────────────

  /// Extracts a document name from the OCR text.
  ///
  /// Strategy:
  /// 1. Split text into lines, trim whitespace.
  /// 2. Skip blank lines and lines that are purely numeric / date-like.
  /// 3. Skip lines that match noise patterns.
  /// 4. Return the first qualifying line (capped at 60 characters).
  static String? _extractDocumentName(String text) {
    if (text.trim().isEmpty) return null;

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    for (final line in lines) {
      // Skip pure numbers (prices, totals, serial fragments)
      if (RegExp(r'^[\d\s.,/$€£¥₹%#\-:+]+$').hasMatch(line)) continue;

      // Skip very short lines (likely abbreviations or noise)
      if (line.length < 3) continue;

      // Skip noise words
      final words = line.split(RegExp(r'\s+'));
      if (words.length == 1 && _noisePatterns.hasMatch(words.first)) continue;

      // Skip lines that look like dates ("June 15, 2025", "15/06/2025", etc.)
      if (RegExp(r'^\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4}$').hasMatch(line)) {
        continue;
      }

      // Must contain at least one alphabetic character
      if (!RegExp(r'[a-zA-Z]').hasMatch(line)) continue;

      // Good candidate — cap length
      return line.length > 60 ? line.substring(0, 60) : line;
    }

    return null;
  }

  // ── Price extraction ──────────────────────────────────────────────────────

  static double? _extractPrice(List<EntityResult> entities) {
    final moneyEntities =
        entities.where((e) => e.type == 'Money').toList();
    if (moneyEntities.isEmpty) return null;

    // Take the largest money amount (likely the total / price)
    double? maxPrice;
    for (final m in moneyEntities) {
      final numStr =
          m.text.replaceAll(RegExp(r'[^\d.]'), '');
      final val = double.tryParse(numStr);
      if (val != null && (maxPrice == null || val > maxPrice)) {
        maxPrice = val;
      }
    }
    return maxPrice;
  }

  // ── Serial / tracking extraction ──────────────────────────────────────────

  static String? _extractSerial(List<EntityResult> entities) {
    final serial = entities.where((e) =>
        e.type == 'Tracking #' ||
        e.type == 'Payment Card' ||
        e.type == 'IBAN');
    return serial.isNotEmpty ? serial.first.text : null;
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

enum _DateHint { start, end, unknown }

class _ParsedDate {
  final DateTime date;
  final _DateHint hint;
  const _ParsedDate(this.date, this.hint);
}
