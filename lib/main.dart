import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'providers/data_providers.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  // Demo mode: No Supabase initialization needed
  runApp(
    const ProviderScope(
      child: NetBakiyeApp(),
    ),
  );
}

class NetBakiyeApp extends ConsumerWidget {
  const NetBakiyeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeName = ref.watch(themeColorProvider);

    return MaterialApp.router(
      title: 'NetBakiye',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(themeName: themeName),
      routerConfig: router,
    );
  }
}
