import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // Cần cho ChangeNotifierProvider trong Riverpod 3

import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/trip_service.dart';
import '../services/activity_service.dart';
import '../services/expense_service.dart';
import '../services/checklist_service.dart';
import 'auth_provider.dart';
import 'theme_provider.dart';

// === Xuất các lớp để màn hình sử dụng trực tiếp ===
export 'auth_provider.dart';
export 'theme_provider.dart';
export '../models/trip.dart';
export '../models/activity.dart';
export '../models/expense.dart';
export '../models/checklist_item.dart';
export '../services/trip_service.dart';
export '../services/activity_service.dart';
export '../services/expense_service.dart';
export '../services/checklist_service.dart';

// === Infrastructure Providers ===
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

// === Service Providers ===
final authServiceProvider = Provider((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

final profileServiceProvider = Provider((ref) {
  return ProfileService(ref.watch(firestoreProvider));
});

final tripServiceProvider = Provider((ref) {
  return TripService(ref.watch(firestoreProvider));
});

final activityServiceProvider = Provider((ref) {
  return ActivityService(ref.watch(firestoreProvider));
});

final expenseServiceProvider = Provider((ref) {
  return ExpenseService(ref.watch(firestoreProvider));
});

final checklistServiceProvider = Provider((ref) {
  return ChecklistService(ref.watch(firestoreProvider));
});

// === UI State Providers ===
final themeProvider = ChangeNotifierProvider((ref) => ThemeProvider());

final authProvider = ChangeNotifierProvider((ref) {
  return AppAuthProvider(
    ref.watch(authServiceProvider),
    ref.watch(profileServiceProvider),
  );
});
