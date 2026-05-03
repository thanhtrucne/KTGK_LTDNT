import 'package:cloud_firestore/cloud_firestore.dart';

class TripMoment {
  TripMoment({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.img64,
    required this.caption,
    required this.createdAt,
    this.userName = '',
  });

  final String id;
  final String tripId;
  final String userId;
  final String img64;
  final String caption;
  final DateTime createdAt;
  final String userName;

  factory TripMoment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TripMoment(
      id: doc.id,
      tripId: data['tripId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      img64: data['img64'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userName: data['userName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'tripId': tripId,
        'userId': userId,
        'img64': img64,
        'caption': caption,
        'createdAt': FieldValue.serverTimestamp(),
        'userName': userName,
      };
}
