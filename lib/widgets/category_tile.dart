import 'package:flutter/material.dart';
import '../models/category.dart';
import '../l10n/localization_service.dart';

class CategoryTile extends StatelessWidget {
  final BudgetCategory category;
  final double amountSpent;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.category,
    required this.amountSpent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: category.color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 36,
                color: category.color,
              ),
              const SizedBox(height: 8),
              Text(
                category.getLocalizedName(l10n),
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.formatCurrency(amountSpent),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
