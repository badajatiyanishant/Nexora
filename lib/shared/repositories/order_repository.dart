import '../models/order.dart';

/// Abstract repository for order data.
///
/// Mock implementation uses in-memory state.
/// Firestore implementation will write to `restaurants/{slug}/orders`.
abstract class OrderRepositoryInterface {
  Future<List<RestaurantOrder>> getOrders(String restaurantId);
  Future<RestaurantOrder> placeOrder(RestaurantOrder order);
  Future<void> updateStatus(String orderId, String status);
  Stream<List<RestaurantOrder>> watchOrders(String restaurantId);
}
