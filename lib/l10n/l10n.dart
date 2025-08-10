import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<void> load() async {
    final code = locale.languageCode;
    final asset = 'lib/l10n/arb/app_$code.arb';
    final data = await rootBundle.loadString(asset).catchError((_) async {
      return await rootBundle.loadString('lib/l10n/arb/app_en.arb');
    });
    final Map<String, dynamic> jsonMap = json.decode(data);
    _strings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String t(String key) => _strings[key] ?? key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final loc = AppLocalizations(locale);
    await loc.load();
    return loc;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
