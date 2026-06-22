import 'package:isar/isar.dart';
import 'package:trezo/core/models/asset.dart';
import 'package:trezo/features/assets/domain/repositories/asset_repository.dart';

class IsarAssetRepository implements AssetRepository {
  final Isar isar;

  IsarAssetRepository(this.isar);

  @override
  Future<int> saveAsset(Asset asset) async {
    if (asset.id != Isar.autoIncrement) {
      asset.updatedAt = DateTime.now();
    }
    late int savedId;
    await isar.writeTxn(() async {
      savedId = await isar.assets.put(asset);
    });
    return savedId;
  }

  @override
  Future<List<Asset>> getAllAssets() async {
    return await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<void> deleteAsset(int id) async {
    await isar.writeTxn(() async {
      await isar.assets.delete(id);
    });
  }

  @override
  Future<void> softDeleteAsset(int id) async {
    await isar.writeTxn(() async {
      final asset = await isar.assets.get(id);
      if (asset != null) {
        asset.isDeleted = true;
        asset.updatedAt = DateTime.now();
        await isar.assets.put(asset);
      }
    });
  }

  @override
  Future<void> updateAsset(Asset asset) async {
    asset.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.assets.put(asset);
    });
  }

  @override
  Future<List<Asset>> getAssetsByStatus(String status) async {
    final all = await getAllAssets();
    return all.where((a) => a.status == status).toList();
  }

  @override
  Future<List<Asset>> getExpiringAssets(int withinDays) async {
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: withinDays));

    return await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .endDateIsNotNull()
        .endDateBetween(now, cutoff)
        .findAll();
  }

  @override
  Future<List<Asset>> getFutureAssets() async {
    final now = DateTime.now();
    return await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .endDateIsNotNull()
        .endDateGreaterThan(now)
        .sortByEndDate()
        .findAll();
  }

  @override
  Future<List<Asset>> getPastAssets() async {
    final now = DateTime.now();
    return await isar.assets
        .filter()
        .isDeletedEqualTo(false)
        .endDateIsNotNull()
        .endDateLessThan(now)
        .sortByEndDateDesc()
        .findAll();
  }

  @override
  Future<List<Asset>> getAssetsNeedingReminder(int daysBeforeExpiry) async {
    final now = DateTime.now();
    final targetDate = now.add(Duration(days: daysBeforeExpiry));
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

  @override
  Future<void> markReminderSent(int assetId, int daysBeforeExpiry) async {
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

  @override
  Future<int> cleanupExpiredAssets({int daysAfterExpiry = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysAfterExpiry));

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

  @override
  Future<List<Asset>> searchAssets(String query) async {
    if (query.trim().isEmpty) return getAllAssets();
    final q = query.toLowerCase();

    final all = await getAllAssets();
    return all.where((a) {
      return a.name.toLowerCase().contains(q) ||
          a.brand.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q) ||
          (a.documentName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Future<Map<String, int>> getStatusCounts() async {
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
