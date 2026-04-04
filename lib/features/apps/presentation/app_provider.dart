import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_repository.dart';
import '../domain/app_model.dart';

final appRepositoryProvider = Provider((ref) => AppRepository());

final appListProvider = StateNotifierProvider<AppListNotifier, AsyncValue<List<AppModel>>>((ref) {
  return AppListNotifier(ref.watch(appRepositoryProvider));
});

class AppListNotifier extends StateNotifier<AsyncValue<List<AppModel>>> {
  final AppRepository _repository;

  AppListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadApps();
  }

  Future<void> loadApps() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getInstalledApps());
  }

  void toggleAllowed(String packageName) {
    state.whenData((apps) {
      final updated = apps.map((app) {
        if (app.packageName == packageName) {
          return app.copyWith(isAllowed: !app.isAllowed);
        }
        return app;
      }).toList();
      state = AsyncValue.data(updated);
      _repository.saveAppSettings(updated);
    });
  }

  void toggleDistracting(String packageName) {
    state.whenData((apps) {
      final updated = apps.map((app) {
        if (app.packageName == packageName) {
          return app.copyWith(isDistracting: !app.isDistracting);
        }
        return app;
      }).toList();
      state = AsyncValue.data(updated);
      _repository.saveAppSettings(updated);
    });
  }

  void reorderAllowedApps(int oldIndex, int newIndex) {
    state.whenData((apps) {
      final allowedApps = apps.where((a) => a.isAllowed).toList();
      final unallowedApps = apps.where((a) => !a.isAllowed).toList();

      if (newIndex > oldIndex) newIndex -= 1;
      final item = allowedApps.removeAt(oldIndex);
      allowedApps.insert(newIndex, item);

      final updated = [...allowedApps, ...unallowedApps];
      state = AsyncValue.data(updated);
      _repository.saveAppSettings(updated);
    });
  }
}
