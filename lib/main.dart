import 'package:flutter/material.dart';
import 'screens/budget_screen.dart';
import 'l10n/localization_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await SettingsService.instance.init();
  
  runApp(const SpendinatorApp());
}

class SpendinatorApp extends StatefulWidget {
  const SpendinatorApp({super.key});

  @override
  State<SpendinatorApp> createState() => _SpendinatorAppState();
}

class _SpendinatorAppState extends State<SpendinatorApp> {
  late String currentLanguage;

  @override
  void initState() {
    super.initState();
    // Load saved language preference
    currentLanguage = SettingsService.instance.getLanguage();
  }

  void toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == 'fr' ? 'en' : 'fr';
      SettingsService.instance.setLanguage(currentLanguage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LocalizationService(
      localizations: LocalizationService.getLocalization(currentLanguage),
      child: MaterialApp(
        title: 'Spendinator',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: BudgetScreen(onLanguageToggle: toggleLanguage),
      ),
    );
  }
}
