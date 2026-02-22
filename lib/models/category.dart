import 'package:flutter/material.dart';

class BudgetCategory {
  final String id;
  final String Function(dynamic) getLocalizedName;
  final IconData icon;
  final Color color;

  const BudgetCategory({
    required this.id,
    required this.getLocalizedName,
    required this.icon,
    required this.color,
  });
}

// Predefined categories
List<BudgetCategory> getDefaultCategories() {
  return [
    BudgetCategory(
      id: 'transport',
      getLocalizedName: (l10n) => l10n.transport,
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    BudgetCategory(
      id: 'meals',
      getLocalizedName: (l10n) => l10n.meals,
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    BudgetCategory(
      id: 'leisure',
      getLocalizedName: (l10n) => l10n.leisure,
      icon: Icons.movie,
      color: Colors.purple,
    ),
    BudgetCategory(
      id: 'shopping',
      getLocalizedName: (l10n) => l10n.shopping,
      icon: Icons.shopping_bag,
      color: Colors.pink,
    ),
    BudgetCategory(
      id: 'health',
      getLocalizedName: (l10n) => l10n.health,
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    BudgetCategory(
      id: 'utilities',
      getLocalizedName: (l10n) => l10n.utilities,
      icon: Icons.lightbulb,
      color: Colors.amber,
    ),
    BudgetCategory(
      id: 'education',
      getLocalizedName: (l10n) => l10n.education,
      icon: Icons.school,
      color: Colors.indigo,
    ),
    BudgetCategory(
      id: 'other',
      getLocalizedName: (l10n) => l10n.other,
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];
}
