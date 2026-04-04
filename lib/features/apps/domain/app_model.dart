class AppModel {
  final String packageName;
  final String appName;
  final bool isAllowed;
  final bool isDistracting;

  AppModel({
    required this.packageName,
    required this.appName,
    this.isAllowed = false,
    this.isDistracting = false,
  });

  AppModel copyWith({
    bool? isAllowed,
    bool? isDistracting,
  }) {
    return AppModel(
      packageName: packageName,
      appName: appName,
      isAllowed: isAllowed ?? this.isAllowed,
      isDistracting: isDistracting ?? this.isDistracting,
    );
  }
}
