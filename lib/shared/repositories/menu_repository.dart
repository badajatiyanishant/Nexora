import '../models/menu.dart';

/// Abstract repository for menu data.
///
/// Mock implementation loads from bundled JSON assets.
/// Firestore implementation will query `restaurants/{slug}/menu`.
abstract class MenuRepositoryInterface {
  Future<Menu> getMenu(String slug);
}
