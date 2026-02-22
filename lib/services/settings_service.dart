import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._init();
  SharedPreferences? _prefs;

  SettingsService._init();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Default monthly budget
  Future<void> setDefaultBudget(double amount) async {
    await _prefs?.setDouble('default_budget', amount);
  }

  double getDefaultBudget() {
    return _prefs?.getDouble('default_budget') ?? 2000.0;
  }

  // Monthly budget overrides (key format: "budget_YYYY_MM")
  Future<void> setMonthlyBudget(DateTime month, double amount) async {
    final key = 'budget_${month.year}_${month.month}';
    await _prefs?.setDouble(key, amount);
  }

  double? getMonthlyBudget(DateTime month) {
    final key = 'budget_${month.year}_${month.month}';
    return _prefs?.getDouble(key);
  }

  Future<void> clearMonthlyBudget(DateTime month) async {
    final key = 'budget_${month.year}_${month.month}';
    await _prefs?.remove(key);
  }

  // Get effective budget for a month (override or default)
  double getBudgetForMonth(DateTime month) {
    return getMonthlyBudget(month) ?? getDefaultBudget();
  }

  // Language preference
  Future<void> setLanguage(String languageCode) async {
    await _prefs?.setString('language', languageCode);
  }

  String getLanguage() {
    return _prefs?.getString('language') ?? 'fr';
  }
}
