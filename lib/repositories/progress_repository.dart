import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress.dart';
import 'base_repository.dart';

class ProgressRepository implements BaseRepository<RoadmapProgress> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'progress';

  @override
  Future<String> create(RoadmapProgress progress) async {
    final docRef = await _db.collection(_collection).add(progress.toJson());
    return docRef.id;
  }

  @override
  Future<RoadmapProgress?> read(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      return RoadmapProgress.fromJson({...doc.data()!, 'id': doc.id});
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
  Stream<List<RoadmapProgress>> getAll() {
    return _db
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoadmapProgress.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<RoadmapProgress?> getUserRoadmapProgress(
      String userId, String roadmapId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('roadmapId', isEqualTo: roadmapId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty
            ? null
            : RoadmapProgress.fromJson(
                {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id}));
  }

  Future<void> updateStepCompletion(
      String progressId, String stepId, bool isCompleted) async {
    await _db.collection(_collection).doc(progressId).update({
      'completedSteps.$stepId': isCompleted,
      'progressPercentage': FieldValue.increment(isCompleted ? 1 : -1),
    });
  }
} 