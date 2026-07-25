import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/nexora_app.dart';

/// Entry point.
///
/// Milestones 1-4 run entirely on mock data, so there is nothing to initialise
/// here yet. Firebase bootstrap is added in Milestone 5.
void main() {
  runApp(const ProviderScope(child: NexoraApp()));
}
