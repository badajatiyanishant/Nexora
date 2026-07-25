/// Abstract repository for table data.
///
/// Firestore implementation will query `restaurants/{slug}/tables`.
abstract class TableRepositoryInterface {
  Future<List<Map<String, dynamic>>> getTables(String restaurantId);
  Future<void> updateTableStatus(String tableId, String status);
}
