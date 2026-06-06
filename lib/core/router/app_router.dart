import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:budget_mate/features/auth/screens/login_screen.dart';
import 'package:budget_mate/features/auth/screens/signup_screen.dart';
import 'package:budget_mate/features/auth/providers/auth_provider.dart';
import 'package:budget_mate/features/dashboard/screens/dashboard_screen.dart';
import 'package:budget_mate/features/plan/screens/plan_screen.dart';
import 'package:budget_mate/features/transactions/screens/transactions_screen.dart';
import 'package:budget_mate/features/variance/screens/variance_screen.dart';
import 'package:budget_mate/features/history/screens/history_screen.dart';
import 'package:budget_mate/core/widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/plan',
            builder: (context, state) => const PlanScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/variance',
            builder: (context, state) => const VarianceScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
      ),
    ],
  );
});