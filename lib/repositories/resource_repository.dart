import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resource.dart';
import 'base_repository.dart';

/// Repository for managing learning resources in Firestore.
/// 
/// Handles:
/// - Resource creation and management
/// - Resource type validation
/// - Resource linking to roadmap steps
/// - Resource retrieval and caching
class ResourceRepository implements BaseRepository<Resource> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'resources';

  /// Creates a new resource and links it to a step.
  /// 
  /// Parameters:
  /// - [resource]: The resource to create
  /// - [stepId]: ID of the step to link the resource to
  /// 
  /// Returns the ID of the created resource.
  Future<String> createAndLink(Resource resource, String stepId) async {
    final batch = _db.batch();
    
    // Create resource
    final resourceRef = _db.collection(_collection).doc();
    batch.set(resourceRef, resource.toJson());
    
    // Link to step
    final stepRef = _db.collection('steps').doc(stepId);
    batch.update(stepRef, {
      'resources': FieldValue.arrayUnion([resourceRef.id])
    });
    
    await batch.commit();
    return resourceRef.id;
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