import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/accounts/accounts_screen.dart';
import 'screens/goals/goals_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = authState.value?.session != null;
      final isAuthPath = state.matchedLocation.startsWith('/auth');

      if (!loggedIn && !isAuthPath) return '/auth/login';
      if (loggedIn && isAuthPath) return '/';
      return null;
    },
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/budget', builder: (context, state) => const BudgetScreen()),
          GoRoute(path: '/accounts', builder: (context, state) => const AccountsScreen()),
          GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen()),
        ],
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});

class AppScaffold extends ConsumerWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int getIndex() {
      if (location == '/') return 0;
      if (location == '/budget') return 1;
      if (location == '/accounts') return 2;
      if (location == '/goals') return 3;
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getIndex(),
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/budget'); break;
            case 2: context.go('/accounts'); break;
            case 3: context.go('/goals'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Özet'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Bütçe'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_outlined), label: 'Hesaplar'),
          BottomNavigationBarItem(icon: Icon(Icons.flag_outlined), label: 'Hedefler'),
        ],
      ),
    );
  }
}
