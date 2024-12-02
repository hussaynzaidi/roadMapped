import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roadmap.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Roadmap>> getPublicRoadmaps() {
    return _db
        .collection('roadmaps')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Roadmap.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<Roadmap>> getUserRoadmaps(String userId) {
    return _db
        .collection('roadmaps')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Roadmap.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Create new roadmap
  Future<String> createRoadmap(Roadmap roadmap) async {
    final docRef = await _db.collection('roadmaps').add(roadmap.toJson());
    return docRef.id;
  }

  // Update roadmap
  Future<void> updateRoadmap(String id, Map<String, dynamic> data) async {
    await _db.collection('roadmaps').doc(id).update(data);
  }

  // Delete roadmap
  Future<void> deleteRoadmap(String id) async {
    await _db.collection('roadmaps').doc(id).delete();
  }
}
