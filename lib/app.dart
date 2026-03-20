import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/accounts/accounts_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/profile_screen.dart';
import 'screens/settings/fixed_payments_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/calendar/calendar_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/transactions', builder: (context, state) => const TransactionsScreen()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
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
      GoRoute(
        path: '/settings/fixed-payments',
        builder: (context, state) => const FixedPaymentsScreen(),
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
      if (location == '/transactions') return 1;
      if (location == '/reports') return 2;
      if (location == '/calendar') return 3;
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getIndex(),
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/transactions'); break;
            case 2: context.go('/reports'); break;
            case 3: context.go('/calendar'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Özet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'İşlemler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline_rounded),
            activeIcon: Icon(Icons.pie_chart_rounded),
            label: 'Raporlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Takvim',
          ),
        ],
      ),
    );
  }
}
