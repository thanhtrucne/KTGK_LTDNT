import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

class ExpenseService {
  ExpenseService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _expenses =>
      _firestore.collection('expenses');

  /// Lắng nghe danh sách chi phí theo chuyến đi (realtime)
  /// Sắp xếp phía client để tránh lỗi thiếu composite index
  Stream<List<Expense>> watchExpenses(String tripId) {
    return _expenses
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(Expense.fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Thêm chi phí mới
  Future<void> addExpense(Expense expense) {
    return _expenses.add(expense.toCreateMap());
  }

  /// Cập nhật chi phí
  Future<void> updateExpense(Expense expense) {
    return _expenses.doc(expense.id).update(expense.toUpdateMap());
  }

  /// Xóa chi phí
  Future<void> deleteExpense(String expenseId) {
    return _expenses.doc(expenseId).delete();
  }
}
