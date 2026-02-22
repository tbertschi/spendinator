import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/localization_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _budgetController;
  late double _currentBudget;

  @override
  void initState() {
    super.initState();
    _currentBudget = SettingsService.instance.getDefaultBudget();
    _budgetController = TextEditingController(text: _currentBudget.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_budgetController.text);
    if (amount != null && amount > 0) {
      await SettingsService.instance.setDefaultBudget(amount);
      if (mounted) {
        final l10n = LocalizationService.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.defaultBudget}: ${l10n.formatCurrency(amount)}')),
        );
        Navigator.pop(context, false); // Return false - default budget doesn't affect current month
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.defaultBudget,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.defaultBudgetDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _budgetController,
                    decoration: InputDecoration(
                      labelText: l10n.budgetAmount,
                      border: const OutlineInputBorder(),
                      prefixText: '${l10n.currencySymbol} ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveBudget,
                      icon: const Icon(Icons.save),
                      label: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
