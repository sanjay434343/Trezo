import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trezo/core/models/asset.dart';
import 'package:trezo/core/di/injection.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  FutureOr<List<Asset>> build() async {
    return _fetchAssets();
  }

  Future<List<Asset>> _fetchAssets() async {
    final repo = ref.watch(assetRepositoryProvider);
    return repo.getAllAssets();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAssets());
  }
}
