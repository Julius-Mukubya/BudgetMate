import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Budget Plan'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: const Center(
        child: Text('Budget Plan — coming soon'),
      ),
    );
  }
}