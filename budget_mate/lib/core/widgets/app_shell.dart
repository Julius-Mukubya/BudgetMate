import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// The main app shell with bottom navigation bar.
///
/// Contains 5 tabs: Dashboard, Budget Plan, Transactions, Variance, History.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surfaceContainerHigh,
        indicatorColor: colorScheme.primary.withAlpha(30),
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.fileSpreadsheet),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.arrowRightLeft),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.barChart3),
            label: 'Variance',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.clock),
            label: 'History',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/plan')) return 1;
    if (location.startsWith('/transactions')) return 2;
    if (location.startsWith('/variance')) return 3;
    if (location.startsWith('/history')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/plan');
        break;
      case 2:
        context.go('/transactions');
        break;
      case 3:
        context.go('/variance');
        break;
      case 4:
        context.go('/history');
        break;
    }
  }
}