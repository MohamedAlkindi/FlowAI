final class GotHomeScreenData {
  final bool isAccessibilityEnabled;
  final String oemBrand;

  GotHomeScreenData({
    required this.isAccessibilityEnabled,
    required this.oemBrand,
  });

  GotHomeScreenData copyWith({
    bool? isAccessibilityEnabled,
    String? oemBrand,
  }) {
    return GotHomeScreenData(
      isAccessibilityEnabled:
          isAccessibilityEnabled ?? this.isAccessibilityEnabled,
      oemBrand: oemBrand ?? this.oemBrand,
    );
  }
}
