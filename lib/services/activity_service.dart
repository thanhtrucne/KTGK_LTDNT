import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity.dart';

class ActivityService {
  ActivityService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _activities =>
      _firestore.collection('activities');

  /// Lắng nghe các hoạt động theo chuyến đi (realtime)
  /// Sắp xếp phía client để tránh lỗi thiếu composite index trên Firestore
  Stream<List<Activity>> watchActivities(String tripId) {
    return _activities
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(Activity.fromFirestore).toList();
          // Sắp xếp theo ngày rồi theo giờ
          list.sort((a, b) {
            final dateCompare = a.date.compareTo(b.date);
            if (dateCompare != 0) return dateCompare;
            return a.time.compareTo(b.time);
          });
          return list;
        });
  }

  /// Thêm hoạt động mới
  Future<void> addActivity(Activity activity) {
    return _activities.add(activity.toMap());
  }

  /// Cập nhật hoạt động
  Future<void> updateActivity(Activity activity) {
    return _activities.doc(activity.id).update(activity.toMap());
  }

  /// Xóa hoạt động
  Future<void> deleteActivity(String activityId) {
    return _activities.doc(activityId).delete();
  }
}
