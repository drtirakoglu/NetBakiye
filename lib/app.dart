import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/accounts/accounts_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/budget', builder: (context, state) => const BudgetScreen()),
          GoRoute(path: '/accounts', builder: (context, state) => const AccountsScreen()),
          GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen()),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const ProfileScreen(),
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
