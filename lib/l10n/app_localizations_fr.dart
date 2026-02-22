import 'app_localizations.dart';

class AppLocalizationsFr extends AppLocalizations {
  @override
  String get appTitle => 'Spendinator';

  @override
  String get budgetOverview => 'Vue d\'ensemble du budget';

  @override
  String get budget => 'Budget';

  @override
  String get expected => 'Attendu';

  @override
  String get spent => 'Dépensé';

  @override
  String get remaining => 'Restant';

  @override
  String get vsExpected => 'vs attendu';

  @override
  String get transport => 'Transport';

  @override
  String get meals => 'Repas';

  @override
  String get leisure => 'Loisirs';

  @override
  String get shopping => 'Achats';

  @override
  String get health => 'Santé';

  @override
  String get utilities => 'Services';

  @override
  String get education => 'Éducation';

  @override
  String get other => 'Autre';

  @override
  String get totalSpent => 'Total dépensé';

  @override
  String get noExpenses => 'Aucune dépense';

  @override
  String addExpense(String category) => 'Ajouter une dépense - $category';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Montant';

  @override
  String get date => 'Date';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String editExpense(String category) => 'Modifier dépense - $category';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String confirmDeleteMessage(String description) => 'Êtes-vous sûr de vouloir supprimer "$description" ?';

  @override
  String get save => 'Enregistrer';

  @override
  String get settings => 'Paramètres';

  @override
  String get defaultBudget => 'Budget mensuel par défaut';

  @override
  String get defaultBudgetDescription => 'Ce montant sera utilisé pour tous les mois sauf modification';

  @override
  String get monthlyBudget => 'Budget du mois';

  @override
  String monthlyBudgetDescription(String month) => 'Budget personnalisé pour $month';

  @override
  String get setBudget => 'Définir le budget';

  @override
  String get useDefault => 'Utiliser par défaut';

  @override
  String get budgetAmount => 'Montant du budget';

  @override
  String get currencySymbol => 'CHF';

  @override
  String formatCurrency(double amount) => '${amount.toStringAsFixed(2)} CHF';

  @override
  String get january => 'Janvier';

  @override
  String get february => 'Février';

  @override
  String get march => 'Mars';

  @override
  String get april => 'Avril';

  @override
  String get may => 'Mai';

  @override
  String get june => 'Juin';

  @override
  String get july => 'Juillet';

  @override
  String get august => 'Août';

  @override
  String get september => 'Septembre';

  @override
  String get october => 'Octobre';

  @override
  String get november => 'Novembre';

  @override
  String get december => 'Décembre';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get exportSuccess => 'Données exportées avec succès';

  @override
  String get exportError => 'Erreur lors de l\'exportation';

  @override
  String get noDataToExport => 'Aucune donnée à exporter';
}
