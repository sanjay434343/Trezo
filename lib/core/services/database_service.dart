import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trezo/core/models/asset.dart';

/// Central Isar-backed database service for the Trezo app.
///
/// All methods are static for convenient access from anywhere in the widget
/// tree. Call [initialize] once during app startup before using any other
/// method.
class DatabaseService {
  static late Isar isar;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Opens the Isar database. Safe to call only once.
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([AssetSchema], directory: dir.path);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Inserts or updates an [asset]. Sets [Asset.updatedAt] automatically when
  /// the asset already has an id.
  static Future<int> saveAsset(Asset asset) async {
    if (asset.id != Isar.autoIncrement) {
      asset.updatedAt = DateTime.now();
    }
    late int savedId;
    await isar.writeTxn(() async {
      savedId = await isar.assets.put(asset);
    });
    return savedId;
  }

  /// Returns every non-deleted asset ordered by creation date (newest first).
  static Future<List<Asset>> getAllAssets() async {
    return await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Hard-deletes the asset with the given [id].
  static Future<void> deleteAsset(int id) async {
    await isar.writeTxn(() async {
      await isar.assets.delete(id);
    });
  }

  /// Soft-deletes the asset (sets [Asset.isDeleted] = true).
  static Future<void> softDeleteAsset(int id) async {
    await isar.writeTxn(() async {
      final asset = await isar.assets.get(id);
      if (asset != null) {
        asset.isDeleted = true;
        asset.updatedAt = DateTime.now();
        await isar.assets.put(asset);
      }
    });
  }

  /// Updates an existing [asset] in place.
  static Future<void> updateAsset(Asset asset) async {
    asset.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.assets.put(asset);
    });
  }

  // ── Status-based queries ──────────────────────────────────────────────────

  /// Returns non-deleted assets whose computed status matches [status].
  /// Valid values: `'active'`, `'expiring'`, `'expired'`.
  static Future<List<Asset>> getAssetsByStatus(String status) async {
    final all = await getAllAssets();
    return all.where((a) => a.status == status).toList();
  }

  /// Returns non-deleted assets whose [Asset.endDate] falls within the next
  /// [withinDays] days (inclusive).
  static Future<List<Asset>> getExpiringAssets(int withinDays) async {
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: withinDays));

    return await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .endDateIsNotNull()
        .endDateBetween(now, cutoff)
        .findAll();
  }

  // ── Future / Past queries ─────────────────────────────────────────────────

  /// Assets whose [endDate] is still in the future (warranty active).
  static Future<List<Asset>> getFutureAssets() async {
    final now = DateTime.now();
    return await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .endDateIsNotNull()
        .endDateGreaterThan(now)
        .sortByEndDate()
        .findAll();
  }

  /// Assets whose [endDate] has already passed (expired).
  static Future<List<Asset>> getPastAssets() async {
    final now = DateTime.now();
    return await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .endDateIsNotNull()
        .endDateLessThan(now)
        .sortByEndDateDesc()
        .findAll();
  }

  // ── Reminder helpers ──────────────────────────────────────────────────────

  /// Returns assets that need a reminder for [daysBeforeExpiry].
  ///
  /// An asset needs a reminder when:
  /// 1. Its [endDate] is exactly [daysBeforeExpiry] days from now (±12 h).
  /// 2. [daysBeforeExpiry] is **not** already in [Asset.reminderSentDays].
  static Future<List<Asset>> getAssetsNeedingReminder(
      int daysBeforeExpiry) async {
    final now = DateTime.now();
    final targetDate = now.add(Duration(days: daysBeforeExpiry));
    // 12-hour window on each side to allow for WorkManager imprecision.
    final windowStart = targetDate.subtract(const Duration(hours: 12));
    final windowEnd = targetDate.add(const Duration(hours: 12));

    final candidates = await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .endDateIsNotNull()
        .endDateBetween(windowStart, windowEnd)
        .findAll();

    return candidates
        .where((a) => !a.reminderSentDays.contains(daysBeforeExpiry))
        .toList();
  }

  /// Records that the [daysBeforeExpiry]-day reminder has been sent for the
  /// asset with [assetId].
  static Future<void> markReminderSent(
      int assetId, int daysBeforeExpiry) async {
    await isar.writeTxn(() async {
      final asset = await isar.assets.get(assetId);
      if (asset != null && !asset.reminderSentDays.contains(daysBeforeExpiry)) {
        asset.reminderSentDays = [
          ...asset.reminderSentDays,
          daysBeforeExpiry,
        ];
        asset.updatedAt = DateTime.now();
        await isar.assets.put(asset);
      }
    });
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  /// Soft-deletes assets that expired more than [daysAfterExpiry] days ago.
  /// Returns the number of assets cleaned up.
  static Future<int> cleanupExpiredAssets({int daysAfterExpiry = 30}) async {
    final cutoff =
        DateTime.now().subtract(Duration(days: daysAfterExpiry));

    final expired = await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .endDateIsNotNull()
        .endDateLessThan(cutoff)
        .findAll();

    if (expired.isEmpty) return 0;

    await isar.writeTxn(() async {
      for (final asset in expired) {
        asset.isDeleted = true;
        asset.updatedAt = DateTime.now();
        await isar.assets.put(asset);
      }
    });

    return expired.length;
  }

  // ── Search ────────────────────────────────────────────────────────────────

  /// Full-text search across [name], [brand], [documentName], and [category].
  static Future<List<Asset>> searchAssets(String query) async {
    if (query.trim().isEmpty) return getAllAssets();
    final q = query.toLowerCase();

    final all = await getAllAssets();
    return all.where((a) {
      return a.name.toLowerCase().contains(q) ||
          a.brand.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q) ||
          (a.documentName?.toLowerCase().contains(q) ?? false) ||
          (a.notes?.toLowerCase().contains(q) ?? false) ||
          (a.scannedRawText?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  // ── Statistics ────────────────────────────────────────────────────────────

  /// Quick counts by status without loading all objects into Dart memory
  /// (still reads from Isar, but avoids full deserialization).
  static Future<Map<String, int>> getStatusCounts() async {
    final all = await getAllAssets();
    int active = 0, expiring = 0, expired = 0;
    for (final a in all) {
      switch (a.status) {
        case 'active':
          active++;
          break;
        case 'expiring':
          expiring++;
          break;
        case 'expired':
          expired++;
          break;
      }
    }
    return {'active': active, 'expiring': expiring, 'expired': expired};
  }
}
