import 'expense.dart';

class BudgetData {
  final DateTime month;
  final double initialAllocation;
  final List<Expense> expenses;

  BudgetData({
    required this.month,
    required this.initialAllocation,
    required this.expenses,
  });

  double get totalSpent {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get remaining {
    return initialAllocation - totalSpent;
  }

  double getSpentByCategory(String categoryId) {
    return expenses
        .where((e) => e.categoryId == categoryId)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> getExpensesByCategory(String categoryId) {
    return expenses
        .where((e) => e.categoryId == categoryId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
