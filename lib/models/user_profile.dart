import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoBase64,
    required this.updatedAt,
    this.role = 'user',
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoBase64;
  final DateTime updatedAt;
  final String role;

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photoBase64: data['img64'] as String? ?? data['photoBase64'] as String?,
      updatedAt: _readDate(data['updatedAt']),
      role: data['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'img64': photoBase64,
      'updatedAt': FieldValue.serverTimestamp(),
      'role': role,
    };
  }

  static DateTime _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
