class UserPreferences {
  final bool isFirstLaunch;
  final bool isAccessibilityEnabled;
  final String triggerPrefix;

  UserPreferences({
    this.isFirstLaunch = true,
    this.isAccessibilityEnabled = false,
    this.triggerPrefix = '/ai',
  });

  UserPreferences copyWith({
    bool? isFirstLaunch,
    bool? isAccessibilityEnabled,
    String? triggerPrefix,
  }) {
    return UserPreferences(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isAccessibilityEnabled:
          isAccessibilityEnabled ?? this.isAccessibilityEnabled,
      triggerPrefix: triggerPrefix ?? this.triggerPrefix,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFirstLaunch': isFirstLaunch,
      'isAccessibilityEnabled': isAccessibilityEnabled,
      'triggerPrefix': triggerPrefix,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      isAccessibilityEnabled: json['isAccessibilityEnabled'] ?? false,
      triggerPrefix: json['triggerPrefix'] ?? '/ai',
    );
  }
}
