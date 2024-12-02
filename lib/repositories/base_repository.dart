abstract class BaseRepository<T> {
  Future<String> create(T item);
  Future<T?> read(String id);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
  Stream<List<T>> getAll();
} 