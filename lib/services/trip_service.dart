import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip.dart';

class TripService {
  TripService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _trips =>
      _firestore.collection('trips');

  /// Lắng nghe danh sách chuyến đi mà người dùng có quyền truy cập
  Stream<List<Trip>> watchTrips(String userId) {
    return _trips
        .where(
          Filter.or(
            Filter('userId', isEqualTo: userId),
            Filter('collaborators', arrayContains: userId),
          ),
        )
        .snapshots()
        .map((s) {
      final trips = s.docs.map(Trip.fromFirestore).toList();
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    });
  }

  /// Tham gia chuyến đi bằng mã (ID)
  Future<void> joinTrip(String tripId, String userId) async {
    final doc = await _trips.doc(tripId).get();
    if (!doc.exists) {
      throw 'Không tìm thấy chuyến đi với mã này.';
    }

    final trip = Trip.fromFirestore(doc);
    if (trip.userId == userId || trip.collaborators.contains(userId)) {
      throw 'Bạn đã tham gia chuyến đi này rồi.';
    }

    await _trips.doc(tripId).update({
      'collaborators': FieldValue.arrayUnion([userId]),
    });
  }

  /// Lắng nghe một chuyến đi cụ thể (realtime)
  Stream<Trip?> watchTrip(String tripId) {
    return _trips.doc(tripId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Trip.fromFirestore(doc);
    });
  }

  /// Thêm chuyến đi mới
  Future<String> addTrip(Trip trip) async {
    final ref = await _trips.add(trip.toCreateMap());
    return ref.id;
  }

  /// Cập nhật chuyến đi
  Future<void> updateTrip(Trip trip) {
    return _trips.doc(trip.id).update(trip.toUpdateMap());
  }

  /// Xóa chuyến đi
  Future<void> deleteTrip(String tripId) {
    return _trips.doc(tripId).delete();
  }
}
