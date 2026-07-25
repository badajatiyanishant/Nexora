import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/widgets.dart';

/// Temporary stand-in for a screen that arrives in a later milestone.
///
/// Every route in the tree resolves from Milestone 1 onward, so navigation,
/// deep links, and the QR URL shape can all be exercised before the real
/// screens exist. Each placeholder is replaced in its own milestone.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.milestone,
    this.icon = Icons.construction_rounded,
    this.showAppBar = true,
  });

  final String title;
  final String milestone;
  final IconData icon;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: EmptyState(
          icon: icon,
          title: title,
          message: 'This screen is built in $milestone.',
        ),
      ),
    );
  }
}
