import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  Activity({
    required this.id,
    required this.tripId,
    required this.name,
    required this.date,
    required this.time,
    this.location = '',
    this.note = '',
  });

  final String id;
  final String tripId;
  final String name;
  final DateTime date;
  final String time; // Ví dụ: "09:00"
  final String location;
  final String note;

  factory Activity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Activity(
      id: doc.id,
      tripId: data['tripId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      date: _readDate(data['date']),
      time: data['time'] as String? ?? '',
      location: data['location'] as String? ?? '',
      note: data['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'tripId': tripId,
        'name': name,
        'date': Timestamp.fromDate(date),
        'time': time,
        'location': location,
        'note': note,
      };

  Activity copyWith({
    String? name,
    DateTime? date,
    String? time,
    String? location,
    String? note,
  }) =>
      Activity(
        id: id,
        tripId: tripId,
        name: name ?? this.name,
        date: date ?? this.date,
        time: time ?? this.time,
        location: location ?? this.location,
        note: note ?? this.note,
      );

  static DateTime _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
