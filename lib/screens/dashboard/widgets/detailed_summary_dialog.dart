import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/data_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class DetailedSummaryDialog extends ConsumerWidget {
  const DetailedSummaryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final history = summary['monthlyHistory'] as List<Map<String, dynamic>>;
    final debts = summary['totalDebts'] as double;
    final assets = summary['totalAssets'] as double;
    
    // Get current month data
    final currentMonthData = history.last;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ayrıntılı Özet Tablo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildTable([
            _buildRow('Banka Borçları', Formatters.formatCurrency(debts), isNegative: true),
            _buildRow('Varlıklar', Formatters.formatCurrency(assets), isNegative: false),
            const Divider(color: Colors.white10, height: 24),
            _buildRow('Bu Ayki Gelir', Formatters.formatCurrency(currentMonthData['income']), isNegative: false),
            _buildRow('Bu Ayki Gider', Formatters.formatCurrency(currentMonthData['expense']), isNegative: true),
            _buildRow('Haftalık Tahmini Gider', Formatters.formatCurrency(currentMonthData['expense'] / 4), isNegative: true),
            const Divider(color: Colors.white10, height: 24),
            _buildRow('Net Durum', Formatters.formatCurrency(currentMonthData['net']), 
                isBold: true, 
                isNegative: currentMonthData['net'] < 0),
          ]),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentStart,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTable(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(String label, String value, {bool isNegative = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isNegative ? AppColors.warning : AppColors.success,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
