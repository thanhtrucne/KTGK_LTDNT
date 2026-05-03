import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';

class ProfileService {
  ProfileService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<UserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  Future<void> ensureProfile(User user, {String? name, String? phone}) async {
    try {
      final ref = _users.doc(user.uid);
      final doc = await ref.get();
      final data = doc.data();
      
      debugPrint('Đang tạo/cập nhật hồ sơ cho: ${user.uid}');
      debugPrint('Dữ liệu nhận được: name=$name, phone=$phone');

      await ref.set({
        'name': (name != null && name.isNotEmpty) ? name : (user.displayName ?? (data?['name'] ?? '')),
        'email': user.email ?? (data?['email'] ?? ''),
        'phone': (phone != null && phone.isNotEmpty) ? phone : (user.phoneNumber ?? (data?['phone'] ?? '')),
        'img64': data?['img64'],
        'role': data?['role'] ?? 'user',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('Lưu hồ sơ thành công!');
    } catch (e) {
      debugPrint('LỖI LƯU HỒ SƠ: $e');
    }
  }

  Future<void> updateProfile(UserProfile profile) {
    return _users
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }
}
