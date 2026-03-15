import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';

import 'widgets/goal_card.dart';
import 'widgets/report_card.dart';
import 'widgets/add_goal_dialog.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);
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
            goalsAsync.when(
              data: (goals) {
                if (goals.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.flag_outlined, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('Henüz hedef eklenmemiş', style: TextStyle(color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('Sağ alttaki butona tıklayarak yeni hedef ekleyin.', 
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: goals.map((goal) {
                    final isCompleted = goal.savedAmount >= goal.targetAmount;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GoalCard(
                        name: goal.name,
                        target: goal.targetAmount,
                        current: goal.savedAmount,
                        category: goal.category,
                        icon: _getGoalIcon(goal.icon),
                        isCompleted: isCompleted,
                        goalId: goal.id,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )),
              error: (err, _) => Center(child: Text('Hedefler yüklenemedi: $err', style: const TextStyle(color: Colors.white))),
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
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddGoalDialog(),
          );
        },
        child: const Icon(Icons.emoji_events_outlined),
      ),
    );
  }

  IconData _getGoalIcon(String? iconName) {
    switch (iconName) {
      case 'car': return Icons.directions_car_filled_outlined;
      case 'beach': return Icons.beach_access_outlined;
      case 'home': return Icons.home_outlined;
      case 'phone': return Icons.phone_android_outlined;
      case 'gift': return Icons.card_giftcard_outlined;
      case 'money': return Icons.attach_money;
      case 'savings': return Icons.savings_outlined;
      case 'education': return Icons.school_outlined;
      case 'health': return Icons.health_and_safety_outlined;
      default: return Icons.flag_outlined;
    }
  }
}
