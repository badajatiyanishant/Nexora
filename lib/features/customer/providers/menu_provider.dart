import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/restaurant_scope.dart';
import '../../../shared/models/menu.dart';
import '../data/tenant_repository.dart';

/// Async provider that loads the menu for the current slug.
final menuProvider = FutureProvider<Menu>(
  dependencies: [restaurantSlugProvider],
  (ref) async {
  final slug = ref.watch(restaurantSlugProvider);
  return TenantRepository.menu(slug);
});
