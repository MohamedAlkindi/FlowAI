import 'dart:ui';

Locale Function(Locale?, Iterable<Locale>)? localeResolutionCallBack(
  Locale? locale,
) {
  (deviceLocale, supported) {
    // If a saved locale is set, use it (handled by locale property).
    if (locale != null) return locale;

    // No saved locale: decide from device locale.
    final deviceCode = deviceLocale?.languageCode;
    if (deviceCode == 'en' || deviceCode == 'ar') {
      // Match device en/ar exactly from supported list
      return supported.firstWhere(
        (l) => l.languageCode == deviceCode,
        orElse: () => const Locale('en'),
      );
    }

    // Device language is neither en nor ar → fallback to English
    return const Locale('en');
  };
  return null;
}
