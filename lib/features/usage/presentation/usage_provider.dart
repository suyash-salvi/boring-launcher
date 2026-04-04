import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/usage_repository.dart';

final usageRepositoryProvider = Provider((ref) => UsageRepository());

final unlockCountProvider = StateNotifierProvider<UnlockNotifier, int>((ref) {
  return UnlockNotifier(ref.watch(usageRepositoryProvider));
});

class UnlockNotifier extends StateNotifier<int> {
  final UsageRepository _repository;

  UnlockNotifier(this._repository) : super(0) {
    _init();
  }

  Future<void> _init() async {
    state = await _repository.getUnlocks();
  }

  Future<void> recordUnlock() async {
    await _repository.incrementUnlocks();
    state = await _repository.getUnlocks();
  }
}
