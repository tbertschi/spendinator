# Localization Guide / Guide de Localisation

## How to Change the Language / Comment changer la langue

### Method 1: Change Default Language / Méthode 1: Changer la langue par défaut

Open `lib/main.dart` and find this line (around line 17):

```dart
String currentLanguage = 'fr';  // 🔧 CHANGE THIS
```

Change the value to:
- `'fr'` for French (CHF currency)
- `'en'` for English ($ currency)

Save the file and the app will hot reload automatically.

### Method 2: Toggle at Runtime / Méthode 2: Basculer en cours d'exécution

Click the **language icon** (🌐) in the top-right corner of the app to toggle between French and English.

## Adding More Languages / Ajouter d'autres langues

1. Create a new file in `lib/l10n/`: `app_localizations_XX.dart` (XX = language code)
2. Copy the content from `app_localizations_fr.dart` or `app_localizations_en.dart`
3. Translate all strings
4. Update `lib/l10n/localization_service.dart` to include your new language:

```dart
static AppLocalizations getLocalization(String languageCode) {
  switch (languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'de':  // Add your language
      return AppLocalizationsDe();
    case 'en':
    default:
      return AppLocalizationsEn();
  }
}
```

## Currency Configuration / Configuration de la devise

Each language file defines its own currency:
- French: CHF (Swiss Francs)
- English: $ (US Dollars)

To change the currency for a language, edit the corresponding file:
- French: `lib/l10n/app_localizations_fr.dart`
- English: `lib/l10n/app_localizations_en.dart`

Look for these methods:
```dart
@override
String get currencySymbol => 'CHF';  // Change this

@override
String formatCurrency(double amount) => '${amount.toStringAsFixed(2)} CHF';  // Change this
```

Common currency formats:
- Swiss Francs: `'12.50 CHF'`
- Euros: `'12.50 €'` or `'€12.50'`
- US Dollars: `'$12.50'`
- British Pounds: `'£12.50'`
