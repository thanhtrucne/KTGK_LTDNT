import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum phân loại trạng thái chuyến đi
enum TripStatus { upcoming, ongoing, completed }

class Trip {
  Trip({
    required this.id,
    required this.name,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.userId,
    required this.createdAt,
    this.description = '',
    this.imageUrl,
    this.imageBase64,
    this.collaborators = const [],
    this.destinations = const [],
  });

  final String id;
  final String name;
  final String location;
  final List<String> destinations;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final DateTime createdAt;
  final String description;
  final String? imageUrl;
  final String? imageBase64;
  final List<String> collaborators;

  /// Tính trạng thái chuyến đi dựa trên ngày hiện tại
  TripStatus get status {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return TripStatus.upcoming;
    if (now.isAfter(endDate)) return TripStatus.completed;
    return TripStatus.ongoing;
  }

  /// Số ngày của chuyến đi
  int get durationDays => endDate.difference(startDate).inDays + 1;

  factory Trip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Trip(
      id: doc.id,
      name: data['name'] as String? ?? '',
      location: data['location'] as String? ?? '',
      startDate: _readDate(data['startDate']),
      endDate: _readDate(data['endDate']),
      userId: data['userId'] as String? ?? '',
      createdAt: _readDate(data['createdAt']),
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      imageBase64: data['img64'] as String?,
      collaborators: List<String>.from(data['collaborators'] ?? []),
      destinations: List<String>.from(data['destinations'] ?? []),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'name': name,
        'location': location,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'description': description,
        'imageUrl': imageUrl,
        'img64': imageBase64,
        'destinations': destinations,
      };

  Map<String, dynamic> toUpdateMap() => {
        'name': name,
        'location': location,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'description': description,
        'imageUrl': imageUrl,
        'img64': imageBase64,
        'collaborators': collaborators,
        'destinations': destinations,
      };

  Trip copyWith({
    String? name,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? imageUrl,
    String? imageBase64,
    List<String>? collaborators,
    List<String>? destinations,
    bool clearImage = false, // Dùng để xóa ảnh
  }) =>
      Trip(
        id: id,
        userId: userId,
        createdAt: createdAt,
        name: name ?? this.name,
        location: location ?? this.location,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        imageBase64: clearImage ? null : (imageBase64 ?? this.imageBase64),
        collaborators: collaborators ?? this.collaborators,
        destinations: destinations ?? this.destinations,
      );

  static DateTime _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
