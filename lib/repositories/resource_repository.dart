import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resource.dart';
import 'base_repository.dart';

class ResourceRepository implements BaseRepository<Resource> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'resources';

  @override
  Future<String> create(Resource resource) async {
    final docRef = await _db.collection(_collection).add(resource.toJson());
    return docRef.id;
  }

  @override
  Future<Resource?> read(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Resource.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _db.collection(_collection).doc(id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  @override
  Stream<List<Resource>> getAll() {
    return _db
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Resource.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<Resource>> getResourcesByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);
    return _db
        .collection(_collection)
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Resource.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<Resource>> getResourcesByType(ResourceType type) {
    return _db
        .collection(_collection)
        .where('type', isEqualTo: type.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Resource.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
} 