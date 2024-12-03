import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roadmap.dart';

/// Core service for Firestore database operations.
/// 
/// Provides centralized database access for:
/// - Roadmap queries and filtering
/// - User data management
/// - Real-time data synchronization
/// 
/// Uses optimized queries and caching for better performance.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retrieves all public roadmaps in real-time.
  /// 
  /// Returns a stream of roadmaps that are:
  /// - Marked as public
  /// - Ordered by creation date (newest first)
  /// - Automatically updates on changes
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

  /// Gets all roadmaps created by a specific user.
  /// 
  /// Parameters:
  /// - [userId]: The ID of the user whose roadmaps to retrieve
  /// 
  /// Returns a real-time stream of the user's roadmaps.
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

  /// Creates a new roadmap in the database.
  /// 
  /// Parameters:
  /// - [roadmap]: The roadmap object to create
  /// 
  /// Returns the ID of the newly created roadmap.
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
