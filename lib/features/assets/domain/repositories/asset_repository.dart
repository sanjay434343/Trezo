import 'package:trezo/core/models/asset.dart';

abstract class AssetRepository {
  Future<int> saveAsset(Asset asset);
  Future<List<Asset>> getAllAssets();
  Future<void> deleteAsset(int id);
  Future<void> softDeleteAsset(int id);
  Future<void> updateAsset(Asset asset);
  Future<List<Asset>> getAssetsByStatus(String status);
  Future<List<Asset>> getExpiringAssets(int withinDays);
  Future<List<Asset>> getFutureAssets();
  Future<List<Asset>> getPastAssets();
  Future<List<Asset>> getAssetsNeedingReminder(int daysBeforeExpiry);
  Future<void> markReminderSent(int assetId, int daysBeforeExpiry);
  Future<int> cleanupExpiredAssets({int daysAfterExpiry = 30});
  Future<List<Asset>> searchAssets(String query);
  Future<Map<String, int>> getStatusCounts();
}
