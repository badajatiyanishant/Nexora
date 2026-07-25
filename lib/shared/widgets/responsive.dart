import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Screen size class, derived from available width rather than device type so
/// it stays correct in a resizable browser window.
enum ScreenSize { mobile, tablet, desktop }

extension ScreenSizeX on ScreenSize {
  bool get isMobile => this == ScreenSize.mobile;
  bool get isTablet => this == ScreenSize.tablet;
  bool get isDesktop => this == ScreenSize.desktop;
  bool get isWide => this != ScreenSize.mobile;
}

/// Resolves the current [ScreenSize] and exposes helpers for responsive
/// layout. Used instead of ad-hoc `MediaQuery.width < 600` checks so all three
/// products break at the same widths.
class Responsive {
  const Responsive._(this.size, this.width);

  final ScreenSize size;
  final double width;

  factory Responsive.of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Responsive._(sizeFor(w), w);
  }

  static ScreenSize sizeFor(double width) {
    if (width < AppBreakpoints.mobile) return ScreenSize.mobile;
    if (width < AppBreakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

  /// Pick a value per size class, falling back to the next smallest given.
  T value<T>({required T mobile, T? tablet, T? desktop}) => switch (size) {
        ScreenSize.mobile => mobile,
        ScreenSize.tablet => tablet ?? mobile,
        ScreenSize.desktop => desktop ?? tablet ?? mobile,
      };

  EdgeInsets get pagePadding => size.isMobile
      ? AppSpacing.pagePaddingMobile
      : AppSpacing.pagePadding;

  /// Column count for a card grid at the current width.
  int gridColumns({int mobile = 1, int tablet = 2, int desktop = 3}) =>
      value(mobile: mobile, tablet: tablet, desktop: desktop);
}

/// Builds different layouts per size class. Prefer this over branching inside
/// a single tree when mobile and desktop layouts genuinely differ.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Responsive.sizeFor(constraints.maxWidth);
        return switch (size) {
          ScreenSize.mobile => mobile(context),
          ScreenSize.tablet => (tablet ?? mobile)(context),
          ScreenSize.desktop => (desktop ?? tablet ?? mobile)(context),
        };
      },
    );
  }
}

/// Constrains content to a comfortable reading width and centres it, so
/// dashboards do not sprawl across ultrawide monitors.
class ContentContainer extends StatelessWidget {
  const ContentContainer({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? Responsive.of(context).pagePadding,
          child: child,
        ),
      ),
    );
  }
}
