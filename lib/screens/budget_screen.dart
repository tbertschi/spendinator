import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../models/budget_data.dart';
import '../models/expense.dart';
import '../widgets/budget_graph.dart';
import '../widgets/category_tile.dart';
import '../l10n/localization_service.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import 'category_detail_screen.dart';
import 'settings_screen.dart';

class BudgetScreen extends StatefulWidget {
  final VoidCallback onLanguageToggle;
  
  const BudgetScreen({super.key, required this.onLanguageToggle});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late DateTime _currentMonth;
  BudgetData? _budgetData;
  late List<BudgetCategory> _categories;
  bool _isLoading = true;
  bool _useDatabaseStorage = true; // Track if database is available

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _categories = getDefaultCategories();
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    setState(() => _isLoading = true);
    
    try {
      final expenses = await DatabaseService.instance.getExpensesByMonth(_currentMonth);
      final budget = SettingsService.instance.getBudgetForMonth(_currentMonth);
      
      setState(() {
        _budgetData = BudgetData(
          month: _currentMonth,
          initialAllocation: budget,
          expenses: expenses,
        );
        _isLoading = false;
        _useDatabaseStorage = true;
      });
    } catch (e) {
      // On web/chrome, database doesn't work - use in-memory storage
      setState(() {
        _budgetData = BudgetData(
          month: _currentMonth,
          initialAllocation: 2000.0,
          expenses: _generateSampleData(),
        );
        _isLoading = false;
        _useDatabaseStorage = false;
      });
    }
  }

  List<Expense> _generateSampleData() {
    // Sample data for testing on Chrome
    return [
      Expense(
        id: '1',
        categoryId: 'transport',
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Bus ticket',
        amount: 25.50,
      ),
      Expense(
        id: '2',
        categoryId: 'meals',
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Lunch at restaurant',
        amount: 45.00,
      ),
      Expense(
        id: '3',
        categoryId: 'leisure',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Cinema tickets',
        amount: 30.00,
      ),
      Expense(
        id: '4',
        categoryId: 'shopping',
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Clothing',
        amount: 120.00,
      ),
    ];
  }

  void _navigateToMonth(int monthOffset) async {
    final newDate = DateTime(
      _currentMonth.year,
      _currentMonth.month + monthOffset,
    );
    
    // Limit to 12 months back
    final oldestAllowed = DateTime(
      DateTime.now().year,
      DateTime.now().month - 11,
    );
    
    if (newDate.isAfter(oldestAllowed) && 
        newDate.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      _currentMonth = newDate;
      await _loadMonthData();
    }
  }

  void _onCategoryTap(BudgetCategory category) async {
    if (_budgetData == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(
          category: category,
          budgetData: _budgetData!,
          onExpenseAdded: (expense) async {
            if (_useDatabaseStorage) {
              try {
                await DatabaseService.instance.insertExpense(expense);
                await _loadMonthData();
              } catch (e) {
                setState(() {
                  _useDatabaseStorage = false;
                  _budgetData?.expenses.add(expense);
                });
              }
            } else {
              // In-memory storage for Chrome testing
              setState(() {
                _budgetData?.expenses.add(expense);
              });
            }
          },
          onExpenseUpdated: (expense) async {
            if (_useDatabaseStorage) {
              try {
                await DatabaseService.instance.updateExpense(expense);
                await _loadMonthData();
              } catch (e) {
                setState(() {
                  _useDatabaseStorage = false;
                  final index = _budgetData?.expenses.indexWhere((e) => e.id == expense.id) ?? -1;
                  if (index != -1) {
                    _budgetData!.expenses[index] = expense;
                  }
                });
              }
            } else {
              // In-memory storage for Chrome testing
              setState(() {
                final index = _budgetData?.expenses.indexWhere((e) => e.id == expense.id) ?? -1;
                if (index != -1) {
                  _budgetData!.expenses[index] = expense;
                }
              });
            }
          },
          onExpenseDeleted: (expenseId) async {
            if (_useDatabaseStorage) {
              try {
                await DatabaseService.instance.deleteExpense(expenseId);
                await _loadMonthData();
              } catch (e) {
                setState(() {
                  _useDatabaseStorage = false;
                  _budgetData?.expenses.removeWhere((e) => e.id == expenseId);
                });
              }
            } else {
              // In-memory storage for Chrome testing
              setState(() {
                _budgetData?.expenses.removeWhere((e) => e.id == expenseId);
              });
            }
          },
        ),
      ),
    );
    
    if (result == true) {
      if (_useDatabaseStorage) {
        await _loadMonthData();
      } else {
        setState(() {}); // Refresh UI for in-memory changes
      }
    }
  }

  String _getMonthYearString(BuildContext context) {
    final l10n = LocalizationService.of(context);
    return '${l10n.monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    
    if (result == true) {
      // Budget was changed, reload data
      await _loadMonthData();
    }
  }

  Future<void> _editMonthlyBudget() async {
    final l10n = LocalizationService.of(context);
    final currentBudget = _budgetData?.initialAllocation ?? SettingsService.instance.getDefaultBudget();
    final controller = TextEditingController(text: currentBudget.toStringAsFixed(0));
    final hasOverride = SettingsService.instance.getMonthlyBudget(_currentMonth) != null;

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.monthlyBudget),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyBudgetDescription(_getMonthYearString(context)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.budgetAmount,
                border: const OutlineInputBorder(),
                prefixText: '${l10n.currencySymbol} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: true,
            ),
            if (hasOverride) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context, -1.0); // Special value to clear override
                },
                icon: const Icon(Icons.clear),
                label: Text(l10n.useDefault),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result == -1.0) {
        // Clear override
        await SettingsService.instance.clearMonthlyBudget(_currentMonth);
      } else {
        // Set override
        await SettingsService.instance.setMonthlyBudget(_currentMonth, result);
      }
      await _loadMonthData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = _currentMonth.year == DateTime.now().year &&
        _currentMonth.month == DateTime.now().month;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _navigateToMonth(-1),
            ),
            Expanded(
              child: Text(
                _getMonthYearString(context),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: isCurrentMonth ? null : () => _navigateToMonth(1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: _editMonthlyBudget,
            tooltip: LocalizationService.of(context).monthlyBudget,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: LocalizationService.of(context).settings,
          ),
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Change language / Changer la langue',
            onPressed: widget.onLanguageToggle,
          ),
        ],
      ),
      body: _isLoading || _budgetData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Budget graph - top quarter
                Expanded(
                  flex: 1,
                  child: BudgetGraph(budgetData: _budgetData!),
                ),
                
                // Category grid - remaining space
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final spent = _budgetData!.getSpentByCategory(category.id);
                        
                        return CategoryTile(
                          category: category,
                          amountSpent: spent,
                          onTap: () => _onCategoryTap(category),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
