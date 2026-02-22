import 'package:flutter/material.dart';
import '../models/budget_data.dart';
import '../l10n/app_localizations.dart';
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

    // Calculate spending per day
    final spendingByDay = <int, double>{};
    for (var expense in budgetData.expenses) {
      final day = expense.date.day;
      spendingByDay[day] = (spendingByDay[day] ?? 0) + expense.amount;
    }

    // Build cumulative spending array (budget remaining each day)
    final budgetRemaining = <double>[];
    double remaining = budgetData.initialAllocation;
    budgetRemaining.add(remaining); // Day 0 (start)
    
    for (int day = 1; day <= daysInMonth; day++) {
      remaining -= (spendingByDay[day] ?? 0);
      budgetRemaining.add(remaining);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary info
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: budgetData.remaining >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.spent,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    l10n.formatCurrency(budgetData.totalSpent),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Line chart
          Expanded(
            child: CustomPaint(
              painter: BudgetLinePainter(
                budgetRemaining: budgetRemaining,
                daysInMonth: daysInMonth,
                currentDay: currentDay,
                initialBudget: budgetData.initialAllocation,
                l10n: l10n,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetLinePainter extends CustomPainter {
  final List<double> budgetRemaining;
  final int daysInMonth;
  final int currentDay;
  final double initialBudget;
  final AppLocalizations l10n;

  BudgetLinePainter({
    required this.budgetRemaining,
    required this.daysInMonth,
    required this.currentDay,
    required this.initialBudget,
    required this.l10n,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Padding for labels
    const leftPadding = 10.0;
    const rightPadding = 10.0;
    const topPadding = 10.0;
    const bottomPadding = 25.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Find min and max for scaling
    final maxBudget = initialBudget;
    final minBudget = budgetRemaining.reduce((a, b) => a < b ? a : b);
    final budgetRange = maxBudget - (minBudget < 0 ? minBudget : 0);
    
    // Avoid division by zero
    if (budgetRange == 0) return;

    // Draw horizontal grid lines every 500 CHF (no labels)
    final increment = 500.0;
    final maxValue = ((maxBudget / increment).ceil() * increment);
    for (double value = 0; value <= maxValue; value += increment) {
      if (value > maxBudget) continue;
      final normalizedValue = (maxBudget - value) / budgetRange;
      final y = topPadding + (chartHeight * normalizedValue);

      // Use darker/thicker line for 0 CHF (over-budget indicator)
      final isZeroLine = value == 0;
      final linePaint = isZeroLine
          ? (Paint()
            ..color = Colors.red.shade700
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke)
          : gridPaint;

      // Grid line
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        linePaint,
      );
    }

    // Draw vertical grid lines and X-axis labels (show 5, 10, 15, 20, 25, 30)
    for (int day = 5; day <= daysInMonth; day += 5) {
      final x = leftPadding + (chartWidth * day / daysInMonth);
      final y = topPadding + chartHeight;

      // Grid line
      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, y),
        gridPaint,
      );

      // X-axis label
      textPainter.text = TextSpan(
        text: '$day',
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y + 5),
      );
    }

    // Draw the budget line
    final path = Path();
    bool firstPoint = true;

    for (int day = 0; day <= daysInMonth; day++) {
      final x = leftPadding + (chartWidth * day / daysInMonth);
      final value = budgetRemaining[day];
      final normalizedValue = (maxBudget - value) / budgetRange;
      final y = topPadding + (chartHeight * normalizedValue);

      if (firstPoint) {
        path.moveTo(x, y);
        firstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw current day marker
    final markerX = leftPadding + (chartWidth * currentDay / daysInMonth);
    final markerPaint = Paint()
      ..color = Colors.red.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(markerX, topPadding),
      Offset(markerX, topPadding + chartHeight),
      markerPaint,
    );

    // Draw current day dot on line
    final currentValue = budgetRemaining[currentDay];
    final normalizedCurrentValue = (maxBudget - currentValue) / budgetRange;
    final markerY = topPadding + (chartHeight * normalizedCurrentValue);

    final dotPaint = Paint()
      ..color = Colors.red.shade600
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(markerX, markerY), 4, dotPaint);
  }

  @override
  bool shouldRepaint(BudgetLinePainter oldDelegate) {
    return oldDelegate.budgetRemaining != budgetRemaining ||
        oldDelegate.currentDay != currentDay;
  }
}

