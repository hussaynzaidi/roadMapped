/// Base repository interface for CRUD operations.
/// 
/// Provides a standard contract for all repositories to implement:
/// - Create: Adds new records
/// - Read: Retrieves existing records
/// - Update: Modifies existing records
/// - Delete: Removes records
/// - GetAll: Retrieves all records as a stream
/// 
/// Type parameter [T] represents the model class being managed.
abstract class BaseRepository<T> {
  /// Creates a new record in the database.
  /// 
  /// Parameters:
  /// - [item]: The item to create
  /// 
  /// Returns the ID of the newly created record.
  /// Throws [FirebaseException] if creation fails.
  Future<String> create(T item);

  /// Retrieves a single record by ID.
  /// 
  /// Parameters:
  /// - [id]: The unique identifier of the record
  /// 
  /// Returns null if no record exists with the given ID.
  /// Throws [FirebaseException] if read operation fails.
  Future<T?> read(String id);

  /// Updates an existing record.
  /// 
  /// Parameters:
  /// - [id]: The ID of the record to update
  /// - [data]: Map of fields to update
  /// 
  /// Throws [FirebaseException] if update fails.
  Future<void> update(String id, Map<String, dynamic> data);

  /// Permanently deletes a record.
  /// 
  /// Parameters:
  /// - [id]: The ID of the record to delete
  /// 
  /// Throws [FirebaseException] if deletion fails.
  Future<void> delete(String id);

  /// Retrieves all records as a real-time stream.
  /// 
  /// Returns a stream that emits an updated list whenever
  /// any record changes in the collection.
  Stream<List<T>> getAll();
} 