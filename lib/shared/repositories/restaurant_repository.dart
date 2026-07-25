import '../models/restaurant.dart';

/// Abstract repository for restaurant data.
///
/// Mock implementation loads from bundled JSON assets.
/// Firestore implementation (Milestone 5) will query `restaurants/{slug}`.
abstract class RestaurantRepositoryInterface {
  Future<Restaurant> getRestaurant(String slug);
}
