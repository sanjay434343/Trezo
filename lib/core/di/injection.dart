import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:trezo/core/services/database_service.dart';
import 'package:trezo/features/assets/domain/repositories/asset_repository.dart';
import 'package:trezo/features/assets/data/repositories/isar_asset_repository.dart';

final isarProvider = Provider<Isar>((ref) {
  return DatabaseService.isar;
});

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return IsarAssetRepository(isar);
});
