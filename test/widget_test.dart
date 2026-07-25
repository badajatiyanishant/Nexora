import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexora/features/auth/screens/splash_screen.dart';

void main() {
  testWidgets('splash renders the Nexora brand', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SplashScreen())),
    );

    // Pump discrete frames rather than settling — the splash runs a repeating
    // shimmer, so pumpAndSettle would never return.
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Nexora'), findsOneWidget);
    expect(find.text('Smart Ordering for Modern Restaurants'), findsOneWidget);
  });
}
