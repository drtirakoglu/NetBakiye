import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../providers/data_providers.dart';
import '../../../models/goal.dart';
import 'package:uuid/uuid.dart';

class AddGoalDialog extends ConsumerStatefulWidget {
  const AddGoalDialog({super.key});

  @override
  ConsumerState<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<AddGoalDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Birikim';

  DateTime? _deadline;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goalCategories = [
    {'name': 'Birikim', 'icon': Icons.savings_outlined},
    {'name': 'Araba', 'icon': Icons.directions_car_outlined},
    {'name': 'Tatil', 'icon': Icons.beach_access_outlined},
    {'name': 'Ev', 'icon': Icons.home_outlined},
    {'name': 'Eğitim', 'icon': Icons.school_outlined},
    {'name': 'Teknoloji', 'icon': Icons.phone_android_outlined},
    {'name': 'Sürpriz Para Girişi', 'icon': Icons.card_giftcard_outlined},
    {'name': 'Sağlık', 'icon': Icons.health_and_safety_outlined},
    {'name': 'Diğer', 'icon': Icons.flag_outlined},
  ];

  final Map<String, String> _iconMap = {
    'Birikim': 'savings',
    'Araba': 'car',
    'Tatil': 'beach',
    'Ev': 'home',
    'Eğitim': 'education',
    'Teknoloji': 'phone',
    'Sürpriz Para Girişi': 'gift',
    'Sağlık': 'health',
    'Diğer': 'flag',
  };

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amountStr = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountStr);

    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ad ve geçerli bir tutar girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final demo = ref.read(demoServiceProvider);
      final userId = demo.currentUserId;

      final goal = AppGoal(
        id: const Uuid().v4(),
        userId: userId,
        name: name,
        category: _selectedCategory,
        targetAmount: amount,
        savedAmount: 0.0,
        deadline: _deadline,
        icon: _iconMap[_selectedCategory] ?? 'flag',
      );

      await demo.createGoal(goal);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Yeni Hedef', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Hedef Adı',
                hintText: 'ör. Yeni Araba Peşinatı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Hedef Tutar (₺)',
                hintText: '0,00',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Kategori', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goalCategories.map((cat) {
                final isSelected = _selectedCategory == cat['name'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat['icon'] as IconData, size: 16, 
                        color: isSelected ? Colors.white : AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(cat['name'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat['name'] as String),
                  backgroundColor: AppColors.card,
                  selectedColor: AppColors.accentStart,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                _deadline != null 
                  ? Formatters.formatDate(_deadline!)
                  : 'Hedef Tarih Seç (opsiyonel)',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentStart),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Oluştur', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
