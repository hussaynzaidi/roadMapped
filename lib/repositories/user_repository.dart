import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'base_repository.dart';

class UserRepository implements BaseRepository<AppUser> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  @override
  Future<String> create(AppUser user) async {
    await _db.collection(_collection).doc(user.id).set(user.toJson());
    return user.id;
  }

  @override
  Future<AppUser?> read(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    return doc.exists ? AppUser.fromJson({...doc.data()!, 'id': doc.id}) : null;
  }

  @override
  Stream<List<AppUser>> getAll() {
    return _db
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppUser.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _db.collection(_collection).doc(id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  Future<void> updateLastLogin(String userId) async {
    await update(userId, {
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }
} 