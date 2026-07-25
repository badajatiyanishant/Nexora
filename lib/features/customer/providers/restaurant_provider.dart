import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/restaurant_scope.dart';
import '../../../shared/models/restaurant.dart';
import '../data/tenant_repository.dart';

/// Async provider that loads the restaurant for the current slug.
final restaurantProvider = FutureProvider<Restaurant>(
  dependencies: [restaurantSlugProvider],
  (ref) async {
  final slug = ref.watch(restaurantSlugProvider);
  return TenantRepository.restaurant(slug);
});
