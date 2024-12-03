import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roadmap.dart';
import 'base_repository.dart';

/// Repository for managing roadmaps in Firestore.
/// 
/// Handles:
/// - CRUD operations for roadmaps
/// - Public/private roadmap filtering
/// - User-specific roadmap queries
/// - Real-time updates via streams
class RoadmapRepository implements BaseRepository<Roadmap> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'roadmaps';

  /// Creates a new roadmap in Firestore.
  /// 
  /// Converts the [Roadmap] object to JSON and stores it.
  /// Returns the generated document ID.
  @override
  Future<String> create(Roadmap roadmap) async {
    final docRef = await _db.collection(_collection).add(roadmap.toJson());
    return docRef.id;
  }

  /// Retrieves a roadmap by its ID.
  /// 
  /// Returns null if no roadmap exists with the given ID.
  /// Converts Firestore document to [Roadmap] object.
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

  /// Gets all public roadmaps.
  /// 
  /// Returns a stream that emits an updated list whenever:
  /// - New public roadmaps are created
  /// - Existing roadmaps are made public/private
  /// - Public roadmaps are deleted
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

  /// Gets all roadmaps created by a specific user.
  /// 
  /// Parameters:
  /// - [userId]: The ID of the user whose roadmaps to retrieve
  /// 
  /// Returns a real-time stream of the user's roadmaps,
  /// ordered by creation date (newest first).
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