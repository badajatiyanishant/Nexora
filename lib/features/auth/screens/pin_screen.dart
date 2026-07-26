import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';

/// PIN entry screen that guards access to Kitchen and Admin dashboards.
///
/// Shows a numeric keypad, shakes on wrong PIN, locks out after 5 failed
/// attempts for 30 seconds. Session persists via SharedPreferences.
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({
    super.key,
    required this.role,
    required this.onSuccess,
  });

  final AuthRole role;
  final VoidCallback onSuccess;

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _error = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  int _lockoutCountdown = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: _ShakeCurve()),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  AuthNotifier get _authNotifier => widget.role == AuthRole.kitchen
      ? ref.read(kitchenAuthProvider.notifier)
      : ref.read(adminAuthProvider.notifier);

  AuthRoleState get _authState => widget.role == AuthRole.kitchen
      ? ref.watch(kitchenAuthProvider)
      : ref.watch(adminAuthProvider);

  void _onKeyPressed(String key) {
    if (_authState.isLockedOut) return;
    if (_pin.length >= 6) return;

    setState(() {
      _pin += key;
      _error = false;
    });

    HapticFeedback.lightImpact();

    // Auto-submit when pin length matches expected
    final expectedLength = widget.role == AuthRole.kitchen ? 4 : 6;
    if (_pin.length == expectedLength) {
      _validate();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = false;
    });
  }

  void _validate() {
    final success = _authNotifier.attemptPin(_pin);
    if (success) {
      HapticFeedback.mediumImpact();
      widget.onSuccess();
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      setState(() => _error = true);

      // Check if locked out
      final state = ref.read(
        widget.role == AuthRole.kitchen
            ? kitchenAuthProvider
            : adminAuthProvider,
      );
      if (state.isLockedOut) {
        _startLockoutCountdown();
      }

      // Clear PIN after shake
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _pin = '');
      });
    }
  }

  void _startLockoutCountdown() {
    _lockoutTimer?.cancel();
    setState(() => _lockoutCountdown = 30);
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutCountdown <= 1) {
        timer.cancel();
        _authNotifier.clearLockout();
        setState(() => _lockoutCountdown = 0);
      } else {
        setState(() => _lockoutCountdown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expectedLength = widget.role == AuthRole.kitchen ? 4 : 6;
    final title = widget.role == AuthRole.kitchen
        ? 'Kitchen Access'
        : 'Admin Access';
    final icon = widget.role == AuthRole.kitchen
        ? Icons.soup_kitchen_rounded
        : Icons.admin_panel_settings_rounded;
    final lockedOut = _authState.isLockedOut;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8102E).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: const Color(0xFFC8102E),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter your PIN to continue',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                // PIN dots
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final shake =
                        _shakeAnimation.value * 16 * (1 - _shakeAnimation.value);
                    return Transform.translate(
                      offset: Offset(
                        _error ? (shake > 0.5 ? shake - 8 : -(shake - 8)) : 0,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(expectedLength, (index) {
                          final filled = index < _pin.length;
                          return Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled
                                  ? (_error
                                      ? const Color(0xFFC62828)
                                      : const Color(0xFFC8102E))
                                  : theme.colorScheme.outlineVariant,
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Error or lockout message
                if (_error && !lockedOut)
                  Text(
                    'Incorrect PIN. Try again.',
                    style: TextStyle(
                      color: const Color(0xFFC62828),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                if (lockedOut)
                  Column(
                    children: [
                      Text(
                        'Too many attempts',
                        style: TextStyle(
                          color: const Color(0xFFC62828),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try again in $_lockoutCountdown seconds',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                // Number pad
                _NumberPad(
                  onKeyPressed: _onKeyPressed,
                  onDelete: _onDelete,
                  enabled: !lockedOut,
                ),

                const SizedBox(height: 24),

                // Back to home
                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onKeyPressed,
    required this.onDelete,
    required this.enabled,
  });

  final ValueChanged<String> onKeyPressed;
  final VoidCallback onDelete;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                if (key.isEmpty) {
                  return const SizedBox(width: 72);
                }
                if (key == '⌫') {
                  return _KeyButton(
                    child: const Icon(Icons.backspace_outlined, size: 22),
                    onTap: enabled ? onDelete : null,
                  );
                }
                return _KeyButton(
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: enabled ? () => onKeyPressed(key) : null,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) {
        setState(() => _pressed = false);
        widget.onTap!();
      } : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: enabled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: AppRadius.brMd,
            boxShadow: enabled ? AppShadows.soft : null,
          ),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: enabled
                    ? const Color(0xFF1A1614)
                    : const Color(0xFF1A1614).withValues(alpha: 0.3),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shake curve: peaks in the middle, zero at start/end.
class _ShakeCurve extends Curve {
  @override
  double transformInternal(double t) {
    return t < 0.5
        ? (t * 2)
        : (1 - (t - 0.5) * 2);
  }
}
