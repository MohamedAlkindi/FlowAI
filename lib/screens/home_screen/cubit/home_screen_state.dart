final class GotHomeScreenData {
  final bool isAccessibilityEnabled;
  final String oemBrand;
  final bool hasOverlayPermission;
  final bool showOverlayDialog;

  GotHomeScreenData({
    required this.isAccessibilityEnabled,
    required this.oemBrand,
    this.hasOverlayPermission = false,
    this.showOverlayDialog = false,
  });

  GotHomeScreenData copyWith({
    bool? isAccessibilityEnabled,
    String? oemBrand,
    bool? hasOverlayPermission,
    bool? showOverlayDialog,
  }) {
    return GotHomeScreenData(
      isAccessibilityEnabled:
          isAccessibilityEnabled ?? this.isAccessibilityEnabled,
      oemBrand: oemBrand ?? this.oemBrand,
      hasOverlayPermission: hasOverlayPermission ?? this.hasOverlayPermission,
      showOverlayDialog: showOverlayDialog ?? this.showOverlayDialog,
    );
  }
}
