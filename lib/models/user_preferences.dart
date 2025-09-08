class UserPreferences {
  final bool isFirstLaunch;
  final bool isAccessibilityEnabled;
  final bool isDialogDismissed;
  final String triggerPrefix;
  final String triggerSuffix;
  final String? localeCode;

  UserPreferences({
    this.isFirstLaunch = true,
    this.isAccessibilityEnabled = false,
    this.isDialogDismissed = false,
    this.triggerPrefix = '/ai',
    this.triggerSuffix = "/",
    this.localeCode,
  });

  UserPreferences copyWith({
    bool? isFirstLaunch,
    bool? isAccessibilityEnabled,
    bool? isDialogDismissed,
    String? triggerPrefix,
    String? triggerSuffix,
    String? localeCode,
  }) {
    return UserPreferences(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isAccessibilityEnabled:
          isAccessibilityEnabled ?? this.isAccessibilityEnabled,
      isDialogDismissed: isDialogDismissed ?? this.isDialogDismissed,
      triggerPrefix: triggerPrefix ?? this.triggerPrefix,
      triggerSuffix: triggerSuffix ?? this.triggerSuffix,
      localeCode: localeCode ?? this.localeCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFirstLaunch': isFirstLaunch,
      'isAccessibilityEnabled': isAccessibilityEnabled,
      'isDialogDismissed': isDialogDismissed,
      'triggerPrefix': triggerPrefix,
      "triggerSuffix": triggerSuffix,
      'localeCode': localeCode,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      isAccessibilityEnabled: json['isAccessibilityEnabled'] ?? false,
      isDialogDismissed: json['isDialogDismissed'] ?? false,
      triggerPrefix: json['triggerPrefix'] ?? '/ai',
      triggerSuffix: json['triggerSuffix'] ?? '/',
      localeCode: json['localeCode'],
    );
  }
}
