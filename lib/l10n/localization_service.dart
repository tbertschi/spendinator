import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

class LocalizationService extends InheritedWidget {
  final AppLocalizations localizations;

  const LocalizationService({
    super.key,
    required this.localizations,
    required super.child,
  });

  static AppLocalizations of(BuildContext context) {
    final service = context.dependOnInheritedWidgetOfExactType<LocalizationService>();
    return service!.localizations;
  }

  @override
  bool updateShouldNotify(LocalizationService oldWidget) {
    return localizations != oldWidget.localizations;
  }

  static AppLocalizations getLocalization(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return AppLocalizationsFr();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }
}
