import 'package:isar/isar.dart';

part 'asset.g.dart';

@collection
class Asset {
  Id id = Isar.autoIncrement;

  // ── Core fields ────────────────────────────────────────────────────────────
  late String name;
  late String brand;
  late String category;
  late String serial;
  late double price;

  // ── Date fields (stored as milliseconds by Isar) ──────────────────────────
  /// The purchase / issue date of the asset or document.
  DateTime? startDate;

  /// The warranty expiry / document end date.
  DateTime? endDate;

  // ── Extra fields ──────────────────────────────────────────────────────────
  String? notes;

  // ── Scanned-content fields ────────────────────────────────────────────────
  /// Title extracted from the scanned document (first prominent text line).
  String? documentName;

  /// The full raw OCR text preserved for future reference.
  String? scannedRawText;

  // ── Reminder tracking & Config ────────────────────────────────────────────
  /// Which "days-before-expiry" reminders have already been sent,
  /// e.g. `[10, 7, 1]`.
  List<int> reminderSentDays = [];
  
  bool reminderOneWeek = true;
  bool reminderOneMonth = true;
  bool reminderOneDay = true;
  bool reminderOnDay = true;
  bool customReminderEnabled = false;
  DateTime? customReminderDate;

  // ── Timestamps ────────────────────────────────────────────────────────────
  late DateTime createdAt;
  DateTime? updatedAt;

  // ── Soft-delete flag ──────────────────────────────────────────────────────
  bool isDeleted = false;

  // ── Icon storage (Isar can't store IconData) ──────────────────────────────
  late int iconCodePoint;
  late String iconFontFamily;
  String? iconFontPackage;

  // ── Availability toggle ───────────────────────────────────────────────────
  late bool isAvailable;

  // ── Computed status (not persisted) ───────────────────────────────────────
  /// Returns `'active'`, `'expiring'`, or `'expired'` based on [endDate].
  ///
  /// * `expired`  — endDate is in the past
  /// * `expiring` — endDate is within the next 10 days
  /// * `active`   — everything else, including assets with no endDate
  @ignore
  double get progressValue {
    // If no explicit doc start date, we can't calculate a true percentage.
    if (endDate == null || startDate == null) return 0.0;
    
    final total = endDate!.difference(startDate!).inMilliseconds;
    if (total <= 0) return 1.0;
    final elapsed = DateTime.now().difference(startDate!).inMilliseconds;
    if (elapsed < 0) return 0.0;
    if (elapsed >= total) return 1.0;
    return elapsed / total;
  }

  @ignore
  String get status {
    if (endDate == null) return 'active';
    final now = DateTime.now();
    
    // Only completely expired at 100% (when the end date is passed)
    if (endDate!.isBefore(now)) return 'expired';
    
    // Absolute threshold: expiring if there are 30 days or less remaining
    if (endDate!.difference(now).inDays <= 30) return 'expiring';
    
    return 'active';
  }

  /// Remaining days until [endDate]. Negative values mean it's past expiry.
  @ignore
  int? get daysUntilExpiry {
    if (endDate == null) return null;
    return endDate!.difference(DateTime.now()).inDays;
  }

  /// `true` when [endDate] is in the future (warranty/document still valid).
  @ignore
  bool get isFuture => endDate != null && endDate!.isAfter(DateTime.now());

  /// `true` when [endDate] is in the past.
  @ignore
  bool get isPast => endDate != null && endDate!.isBefore(DateTime.now());

  // ── Isar indexes for fast queries ─────────────────────────────────────────
  @Index()
  DateTime? get indexEndDate => endDate;

  @Index()
  bool get indexIsDeleted => isDeleted;
}
