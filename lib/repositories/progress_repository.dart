import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress.dart';
import 'base_repository.dart';

/// Repository for managing roadmap progress in Firestore.
///
/// Responsibilities:
/// - CRUD operations for progress records
/// - Real-time progress tracking via streams
/// - Progress calculation and updates
/// - Step completion management
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

  /// Retrieves all progress records from Firestore.
  ///
  /// Returns a stream of [RoadmapProgress] lists that updates in real-time
  /// when any progress record changes.
  @override
  Stream<List<RoadmapProgress>> getAll() {
    return _db.collection(_collection).snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => RoadmapProgress.fromJson({...doc.data(), 'id': doc.id}))
        .toList());
  }

  /// Gets the progress for a specific user's roadmap.
  ///
  /// Parameters:
  /// - [userId]: The ID of the user
  /// - [roadmapId]: The ID of the roadmap
  ///
  /// Returns a stream that emits null if no progress exists,
  /// or the current [RoadmapProgress] if found.
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

  /// Updates the completion status of a specific step.
  ///
  /// Parameters:
  /// - [progressId]: The ID of the progress record
  /// - [stepId]: The ID of the step being updated
  /// - [isCompleted]: The new completion status
  /// - [totalSteps]: Total number of steps for percentage calculation
  ///
  /// Automatically recalculates the overall progress percentage.
  Future<void> updateStepCompletion(String progressId, String stepId,
      bool isCompleted, int totalSteps) async {
    final doc = await _db.collection(_collection).doc(progressId).get();
    if (!doc.exists) return;

    final progress = RoadmapProgress.fromJson({...doc.data()!, 'id': doc.id});
    final updatedSteps = Map<String, bool>.from(progress.completedSteps);
    updatedSteps[stepId] = isCompleted;

    final completedCount = updatedSteps.values.where((v) => v).length;
    final newProgressPercentage = completedCount / totalSteps;

    await _db.collection(_collection).doc(progressId).update({
      'completedSteps': updatedSteps,
      'progressPercentage': newProgressPercentage,
      if (newProgressPercentage >= 1.0 && progress.completedAt == null)
        'completedAt': FieldValue.serverTimestamp(),
      if (newProgressPercentage < 1.0 && progress.completedAt != null)
        'completedAt': null,
    });
  }

  /// Gets all progress records for a specific user.
  ///
  /// Parameters:
  /// - [userId]: The ID of the user
  ///
  /// Returns a stream of all progress records for the user.
  Stream<List<RoadmapProgress>> getAllUserProgress(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                RoadmapProgress.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
