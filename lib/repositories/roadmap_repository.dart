import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roadmap.dart';
import 'base_repository.dart';

class RoadmapRepository implements BaseRepository<Roadmap> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'roadmaps';

  @override
  Future<String> create(Roadmap roadmap) async {
    final docRef = await _db.collection(_collection).add(roadmap.toJson());
    return docRef.id;
  }

  @override
  Future<Roadmap?> read(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Roadmap.fromJson({...doc.data()!, 'id': doc.id});
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
  Stream<List<Roadmap>> getAll() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Roadmap.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<Roadmap>> getPublicRoadmaps() {
    return _db
        .collection(_collection)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Roadmap.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<Roadmap>> getUserRoadmaps(String userId) {
    return _db
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Roadmap.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
} 