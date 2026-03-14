import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';
import 'widgets/goal_card.dart';
import 'widgets/report_card.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiAnalysisAsync = ref.watch(aiAnalysisProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hedefler & Raporlar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Finansal Hedefler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const GoalCard(
              name: 'Yeni Araba Peşinatı',
              target: 450000,
              current: 125000,
              icon: Icons.directions_car_filled_outlined,
            ),
            const SizedBox(height: 12),
            const GoalCard(
              name: 'Yaz Tatili 2026',
              target: 60000,
              current: 60000, // Completed for demo
              icon: Icons.beach_access_outlined,
              isCompleted: true,
            ),
            const SizedBox(height: 32),
            const Text(
              'Röntgen Raporu (AI)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            aiAnalysisAsync.when(
              data: (content) => ReportCard(content: content),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )),
              error: (err, _) => ReportCard(content: "Analiz şu an sunulamıyor: $err"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.emoji_events_outlined),
      ),
    );
  }
}
