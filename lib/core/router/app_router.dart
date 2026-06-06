import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:budget_mate/features/auth/screens/login_screen.dart';
import 'package:budget_mate/features/auth/screens/signup_screen.dart';
import 'package:budget_mate/features/auth/providers/auth_provider.dart';
import 'package:budget_mate/features/periods/screens/periods_screen.dart';
import 'package:budget_mate/features/plan/screens/plan_screen.dart';
import 'package:budget_mate/features/transactions/screens/transactions_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/periods',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/periods';
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
      GoRoute(
        path: '/periods',
        builder: (context, state) => const PeriodsScreen(),
      ),
      GoRoute(
        path: '/periods/:periodId/plan',
        builder: (context, state) => PlanScreen(
          periodId: state.pathParameters['periodId']!,
        ),
      ),
      GoRoute(
        path: '/periods/:periodId/transactions',
        builder: (context, state) => TransactionsScreen(
          periodId: state.pathParameters['periodId']!,
        ),
      ),
    ],
  );
});