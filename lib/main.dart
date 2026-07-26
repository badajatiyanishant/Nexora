import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/nexora_app.dart';
import 'features/auth/providers/auth_provider.dart';

/// Entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await initAuthProviders();
  runApp(ProviderScope(overrides: overrides, child: const NexoraApp()));
}
