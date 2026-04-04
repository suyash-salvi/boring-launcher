import 'package:shared_preferences/shared_preferences.dart';

class UsageRepository {
  static const _unlocksKey = 'unlocks_count';
  static const _lastDateKey = 'last_unlock_date';

  Future<int> getUnlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_lastDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastDate != today) {
      await prefs.setString(_lastDateKey, today);
      await prefs.setInt(_unlocksKey, 0);
      return 0;
    }
    return prefs.getInt(_unlocksKey) ?? 0;
  }

  Future<void> incrementUnlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getUnlocks();
    await prefs.setInt(_unlocksKey, current + 1);
  }
}
