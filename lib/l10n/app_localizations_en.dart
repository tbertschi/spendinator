import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  @override
  String get appTitle => 'Spendinator';

  @override
  String get budgetOverview => 'Budget Overview';

  @override
  String get budget => 'Budget';

  @override
  String get expected => 'Expected';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get vsExpected => 'vs expected';

  @override
  String get transport => 'Transport';

  @override
  String get meals => 'Meals';

  @override
  String get leisure => 'Leisure';

  @override
  String get shopping => 'Shopping';

  @override
  String get health => 'Health';

  @override
  String get utilities => 'Utilities';

  @override
  String get education => 'Education';

  @override
  String get other => 'Other';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get noExpenses => 'No expenses yet';

  @override
  String addExpense(String category) => 'Add $category Expense';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String editExpense(String category) => 'Edit $category Expense';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteMessage(String description) => 'Are you sure you want to delete "$description"?';

  @override
  String get save => 'Save';

  @override
  String get settings => 'Settings';

  @override
  String get defaultBudget => 'Default Monthly Budget';

  @override
  String get defaultBudgetDescription => 'This amount will be used for all months unless overridden';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String monthlyBudgetDescription(String month) => 'Custom budget for $month';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get useDefault => 'Use Default';

  @override
  String get budgetAmount => 'Budget Amount';

  @override
  String get currencySymbol => '\$';

  @override
  String formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';
}
