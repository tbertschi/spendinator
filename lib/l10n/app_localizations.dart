abstract class AppLocalizations {
  String get appTitle;
  String get budgetOverview;
  String get budget;
  String get expected;
  String get spent;
  String get remaining;
  String get vsExpected;
  
  // Categories
  String get transport;
  String get meals;
  String get leisure;
  String get shopping;
  String get health;
  String get utilities;
  String get education;
  String get other;
  
  // Category detail
  String get totalSpent;
  String get noExpenses;
  String addExpense(String category);
  String get description;
  String get amount;
  String get date;
  String get cancel;
  String get add;
  String get edit;
  String get delete;
  String editExpense(String category);
  String get confirmDelete;
  String confirmDeleteMessage(String description);
  String get save;
  
  // Settings
  String get settings;
  String get defaultBudget;
  String get defaultBudgetDescription;
  String get monthlyBudget;
  String monthlyBudgetDescription(String month);
  String get setBudget;
  String get useDefault;
  String get budgetAmount;
  
  // Currency
  String get currencySymbol;
  String formatCurrency(double amount);
  
  // Months
  String get january;
  String get february;
  String get march;
  String get april;
  String get may;
  String get june;
  String get july;
  String get august;
  String get september;
  String get october;
  String get november;
  String get december;
  
  // Export
  String get exportData;
  String get exportSuccess;
  String get exportError;
  String get noDataToExport;
  
  List<String> get monthNames => [
        january, february, march, april, may, june,
        july, august, september, october, november, december
      ];
}
