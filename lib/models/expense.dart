import 'package:cloud_firestore/cloud_firestore.dart';

/// Danh mục chi phí
enum ExpenseCategory {
  dining('Ăn uống', 'dining'),
  transport('Di chuyển', 'transport'),
  hotel('Khách sạn', 'hotel'),
  other('Khác', 'other');

  const ExpenseCategory(this.label, this.value);
  final String label;
  final String value;

  static ExpenseCategory fromValue(String value) =>
      ExpenseCategory.values.firstWhere(
        (e) => e.value == value,
        orElse: () => ExpenseCategory.other,
      );
}

class Expense {
  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String tripId;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime createdAt;

  factory Expense.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Expense(
      id: doc.id,
      tripId: data['tripId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: ExpenseCategory.fromValue(data['category'] as String? ?? 'other'),
      createdAt: _readDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'tripId': tripId,
        'title': title,
        'amount': amount,
        'category': category.value,
        'createdAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        'title': title,
        'amount': amount,
        'category': category.value,
      };

  Expense copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
  }) =>
      Expense(
        id: id,
        tripId: tripId,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        createdAt: createdAt,
      );

  static DateTime _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
