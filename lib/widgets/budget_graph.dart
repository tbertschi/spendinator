import 'package:flutter/material.dart';
import '../models/budget_data.dart';
import '../l10n/localization_service.dart';

class BudgetGraph extends StatelessWidget {
  final BudgetData budgetData;

  const BudgetGraph({super.key, required this.budgetData});

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.of(context);
    final daysInMonth = DateTime(
      budgetData.month.year,
      budgetData.month.month + 1,
      0,
    ).day;

    final currentDay = budgetData.month.year == DateTime.now().year &&
            budgetData.month.month == DateTime.now().month
        ? DateTime.now().day
        : daysInMonth;

    // Calculate daily budget allocation
    final dailyBudget = budgetData.initialAllocation / daysInMonth;
    
    // Calculate expected spending by current day
    final expectedSpending = dailyBudget * currentDay;
    final actualSpending = budgetData.totalSpent;
    final difference = expectedSpending - actualSpending;
    
    // Calculate percentage
    final percentageSpent = (actualSpending / budgetData.initialAllocation * 100);
    final expectedPercentage = (expectedSpending / budgetData.initialAllocation * 100);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.budgetOverview,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            
            // Budget bars
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Initial allocation
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.formatCurrency(budgetData.initialAllocation).replaceAll('.00', ''),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.budget,
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Expected spending
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.formatCurrency(expectedSpending).replaceAll('.00', ''),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: (expectedPercentage / 100 * 60),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.expected,
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Actual spending
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.formatCurrency(actualSpending).replaceAll('.00', ''),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: (percentageSpent / 100 * 60),
                          decoration: BoxDecoration(
                            color: actualSpending > expectedSpending
                                ? Colors.red.shade400
                                : Colors.green.shade400,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.spent,
                            style: const TextStyle(fontSize: 9, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.remaining,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      l10n.formatCurrency(budgetData.remaining),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: budgetData.remaining >= 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                    ),
                  ],
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: difference >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${difference >= 0 ? "+" : ""}${l10n.formatCurrency(difference.abs()).replaceAll('.00', '')} ${l10n.vsExpected}',
                      style: TextStyle(
                        color: difference >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
