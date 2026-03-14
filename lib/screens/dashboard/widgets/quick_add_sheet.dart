import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key});

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Gıda';

  final List<String> _categories = ['Gıda', 'Ulaşım', 'Faturalar', 'Eğlence', 'Sağlık', 'Diğer'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Hızlı Harcama Gir',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            autofocus: true,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            decoration: const InputDecoration(
              hintText: '0,00 ₺',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.calculate_outlined, size: 32),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text('Kategori Seçin', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                  backgroundColor: AppColors.card,
                  selectedColor: AppColors.accentStart,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('Taksit Sayısı', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [1, 2, 3, 6, 9, 12].map((n) {
                final isSelected = _installmentCount == n;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(n == 1 ? 'Peşin' : '$n Taksit'),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _installmentCount = n),
                    backgroundColor: AppColors.card,
                    selectedColor: AppColors.accentEnd,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentStart,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  int _installmentCount = 1;
}
