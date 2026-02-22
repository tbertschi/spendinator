class Expense {
  final String id;
  final String categoryId;
  final DateTime date;
  final String description;
  final double amount;

  Expense({
    required this.id,
    required this.categoryId,
    required this.date,
    required this.description,
    required this.amount,
  });

  Expense copyWith({
    String? id,
    String? categoryId,
    DateTime? date,
    String? description,
    double? amount,
  }) {
    return Expense(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
    );
  }
}
