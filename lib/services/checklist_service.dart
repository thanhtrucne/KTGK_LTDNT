import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/checklist_item.dart';

class ChecklistService {
  ChecklistService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _checklists =>
      _firestore.collection('checklists');

  /// Lắng nghe danh sách checklist theo chuyến đi (realtime)
  Stream<List<ChecklistItem>> watchChecklist(String tripId) {
    return _checklists
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((s) => s.docs.map(ChecklistItem.fromFirestore).toList());
  }

  /// Thêm mục checklist mới
  Future<void> addItem(ChecklistItem item) {
    return _checklists.add(item.toCreateMap());
  }

  /// Cập nhật trạng thái đánh dấu (isDone)
  Future<void> toggleItem(String itemId, bool isDone) {
    return _checklists.doc(itemId).update({'isDone': isDone});
  }

  /// Sửa tiêu đề
  Future<void> updateItem(ChecklistItem item) {
    return _checklists.doc(item.id).update({'title': item.title});
  }

  /// Xóa mục
  Future<void> deleteItem(String itemId) {
    return _checklists.doc(itemId).delete();
  }
}
