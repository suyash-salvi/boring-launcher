import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_model.dart';

class AppRepository {
  static const _allowedKey = 'allowed_apps_ordered';
  static const _distractingKey = 'distracting_apps';

  Future<List<AppModel>> getInstalledApps() async {
    final apps = await InstalledApps.getInstalledApps();
    final prefs = await SharedPreferences.getInstance();
    final allowed = prefs.getStringList(_allowedKey) ?? [];
    final distracting = prefs.getStringList(_distractingKey) ?? [];

    final appModels = apps.map((app) {
      return AppModel(
        packageName: app.packageName ?? '',
        appName: app.name ?? '',
        isAllowed: allowed.contains(app.packageName),
        isDistracting: distracting.contains(app.packageName),
      );
    }).toList();

    // Separate allowed and unallowed
    final allowedModels = <AppModel>[];
    final unallowedModels = <AppModel>[];

    for (var app in appModels) {
      if (app.isAllowed) {
        allowedModels.add(app);
      } else {
        unallowedModels.add(app);
      }
    }

    // Sort allowed models based on the saved order
    allowedModels.sort((a, b) {
      int indexA = allowed.indexOf(a.packageName);
      int indexB = allowed.indexOf(b.packageName);
      return indexA.compareTo(indexB);
    });

    // Sort unallowed models alphabetically
    unallowedModels.sort((a, b) => a.appName.compareTo(b.appName));

    return [...allowedModels, ...unallowedModels];
  }

  Future<void> saveAppSettings(List<AppModel> apps) async {
    final prefs = await SharedPreferences.getInstance();
    // The order here matters for the home screen
    final allowed = apps.where((a) => a.isAllowed).map((a) => a.packageName).toList();
    final distracting = apps.where((a) => a.isDistracting).map((a) => a.packageName).toList();
    
    await prefs.setStringList(_allowedKey, allowed);
    await prefs.setStringList(_distractingKey, distracting);
  }
}
