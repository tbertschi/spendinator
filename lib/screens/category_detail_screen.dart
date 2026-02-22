import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../models/budget_data.dart';
import '../models/expense.dart';
import '../l10n/localization_service.dart';

class CategoryDetailScreen extends StatefulWidget {
  final BudgetCategory category;
  final BudgetData budgetData;
  final Function(Expense) onExpenseAdded;
  final Function(Expense) onExpenseUpdated;
  final Function(String) onExpenseDeleted;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.budgetData,
    required this.onExpenseAdded,
    required this.onExpenseUpdated,
    required this.onExpenseDeleted,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late List<Expense> _expenses;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _expenses = widget.budgetData.getExpensesByCategory(widget.category.id);
    });
  }

  void _showEditExpenseDialog(Expense expense) {
    final l10n = LocalizationService.of(context);
    final descriptionController = TextEditingController(text: expense.description);
    final amountController = TextEditingController(text: expense.amount.toString());
    DateTime selectedDate = expense.date;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.editExpense(widget.category.getLocalizedName(l10n))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    border: const OutlineInputBorder(),
                    prefixText: '${l10n.currencySymbol} ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(l10n.date),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(
                        widget.budgetData.month.year,
                        widget.budgetData.month.month,
                      ),
                      lastDate: DateTime(
                        widget.budgetData.month.year,
                        widget.budgetData.month.month + 1,
                      ).subtract(const Duration(days: 1)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (descriptionController.text.isEmpty ||
                    amountController.text.isEmpty) {
                  return;
                }

                final updatedExpense = expense.copyWith(
                  description: descriptionController.text,
                  amount: double.parse(amountController.text),
                  date: selectedDate,
                );

                Navigator.pop(context);
                await widget.onExpenseUpdated(updatedExpense);
                // Update local list to show the changes immediately
                if (mounted) {
                  setState(() {
                    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
                    if (index != -1) {
                      _expenses[index] = updatedExpense;
                      _expenses.sort((a, b) => b.date.compareTo(a.date));
                    }
                  });
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteExpense(Expense expense) {
    final l10n = LocalizationService.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage(expense.description)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await widget.onExpenseDeleted(expense.id);
              // Update local list to remove the expense immediately
              if (mounted) {
                setState(() {
                  _expenses.removeWhere((e) => e.id == expense.id);
                });
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showExpenseOptions(Expense expense) {
    final l10n = LocalizationService.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(context);
                _showEditExpenseDialog(expense);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteExpense(expense);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog() {
    final l10n = LocalizationService.of(context);
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addExpense(widget.category.getLocalizedName(l10n))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    border: const OutlineInputBorder(),
                    prefixText: '${l10n.currencySymbol} ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(l10n.date),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(
                        widget.budgetData.month.year,
                        widget.budgetData.month.month,
                      ),
                      lastDate: DateTime(
                        widget.budgetData.month.year,
                        widget.budgetData.month.month + 1,
                      ).subtract(const Duration(days: 1)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (descriptionController.text.isEmpty ||
                    amountController.text.isEmpty) {
                  return;
                }

                final expense = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  categoryId: widget.category.id,
                  date: selectedDate,
                  description: descriptionController.text,
                  amount: double.parse(amountController.text),
                );

                Navigator.pop(context);
                await widget.onExpenseAdded(expense);
                // Update local list to show the new expense immediately
                if (mounted) {
                  setState(() {
                    _expenses.add(expense);
                    _expenses.sort((a, b) => b.date.compareTo(a.date));
                  });
                }
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.of(context);
    final total = _expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.category.color.withValues(alpha: 0.2),
        title: Row(
          children: [
            Icon(widget.category.icon, color: widget.category.color),
            const SizedBox(width: 8),
            Text(widget.category.getLocalizedName(l10n)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Total spent card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.category.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  l10n.totalSpent,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.formatCurrency(total),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: widget.category.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          // Expenses list
          Expanded(
            child: _expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.category.icon,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noExpenses,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: widget.category.color.withValues(alpha: 0.2),
                          child: Icon(
                            widget.category.icon,
                            color: widget.category.color,
                            size: 20,
                          ),
                        ),
                        title: Text(expense.description),
                        subtitle: Text(
                          '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        ),
                        trailing: Text(
                          l10n.formatCurrency(expense.amount),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: widget.category.color,
                              ),
                        ),
                        onTap: () => _showExpenseOptions(expense),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: widget.category.color,
        child: const Icon(Icons.add),
      ),
    );
  }
}
