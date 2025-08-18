class UserPreferences {
  final bool isFirstLaunch;
  final bool isAccessibilityEnabled;
  final String triggerPrefix;
  final String triggerSuffix;

  UserPreferences({
    this.isFirstLaunch = true,
    this.isAccessibilityEnabled = false,
    this.triggerPrefix = '/ai',
    this.triggerSuffix = "/",
  });

  UserPreferences copyWith({
    bool? isFirstLaunch,
    bool? isAccessibilityEnabled,
    String? triggerPrefix,
    String? triggerSuffix,
  }) {
    return UserPreferences(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isAccessibilityEnabled:
          isAccessibilityEnabled ?? this.isAccessibilityEnabled,
      triggerPrefix: triggerPrefix ?? this.triggerPrefix,
      triggerSuffix: triggerSuffix ?? this.triggerSuffix,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFirstLaunch': isFirstLaunch,
      'isAccessibilityEnabled': isAccessibilityEnabled,
      'triggerPrefix': triggerPrefix,
      "triggerSuffix": triggerSuffix,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      isAccessibilityEnabled: json['isAccessibilityEnabled'] ?? false,
      triggerPrefix: json['triggerPrefix'] ?? '/ai',
      triggerSuffix: json['triggerSuffix'] ?? '/',
    );
  }
}
