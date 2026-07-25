import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Identifies the restaurant a customer is currently ordering from.
///
/// The tenant shell resolves the slug from the URL exactly once and overrides
/// this provider for the whole subtree, so no screen ever parses a slug or
/// receives a restaurant id as a constructor argument. Reading it outside a
/// resolved shell is a programming error, hence the throw.
final restaurantSlugProvider = Provider<String>(
  (ref) => throw UnimplementedError(
    'restaurantSlugProvider must be overridden by the tenant shell',
  ),
);

/// Table the diner scanned into, or null for takeaway and browse-only visits.
final tableIdProvider = Provider<String?>((ref) => null);

/// Scopes a subtree to one restaurant.
///
/// Milestone 5 replaces the pass-through below with a real `slugs/{slug}`
/// lookup that maps the public slug to an immutable `restaurantId`; the
/// override boundary established here is what makes that swap invisible to
/// every screen.
class RestaurantScope extends StatelessWidget {
  const RestaurantScope({
    super.key,
    required this.slug,
    required this.tableId,
    required this.child,
  });

  final String slug;
  final String? tableId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        restaurantSlugProvider.overrideWithValue(slug),
        tableIdProvider.overrideWithValue(tableId),
      ],
      child: child,
    );
  }
}
