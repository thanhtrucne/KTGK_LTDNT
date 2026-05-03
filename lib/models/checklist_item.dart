import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistItem {
  ChecklistItem({
    required this.id,
    required this.tripId,
    required this.title,
    this.isDone = false,
  });

  final String id;
  final String tripId;
  final String title;
  final bool isDone;

  factory ChecklistItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChecklistItem(
      id: doc.id,
      tripId: data['tripId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      isDone: data['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'tripId': tripId,
        'title': title,
        'isDone': isDone,
      };

  ChecklistItem copyWith({String? title, bool? isDone}) => ChecklistItem(
        id: id,
        tripId: tripId,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
      );
}
