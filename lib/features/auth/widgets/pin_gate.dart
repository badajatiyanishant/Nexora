import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/pin_screen.dart';

/// Wraps a protected screen with PIN authentication.
///
/// If the user is authenticated (session), shows [child].
/// Otherwise shows [PinScreen] for the given [role].
/// Typing the URL directly still hits this gate.
class PinGate extends ConsumerWidget {
  const PinGate({
    super.key,
    required this.role,
    required this.child,
  });

  final AuthRole role;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(
      role == AuthRole.kitchen ? kitchenAuthProvider : adminAuthProvider,
    );

    if (authState.isAuthenticated) {
      return child;
    }

    return PinScreen(
      role: role,
      onSuccess: () {
        // State is already updated in the provider.
        // The ConsumerWidget will rebuild automatically.
      },
    );
  }
}
