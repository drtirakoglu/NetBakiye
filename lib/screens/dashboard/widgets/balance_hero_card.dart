import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import 'detailed_summary_dialog.dart';

class BalanceHeroCard extends StatelessWidget {
  final double netBalance;
  final double assets;
  final double debts;

  const BalanceHeroCard({
    super.key,
    required this.netBalance,
    required this.assets,
    required this.debts,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = netBalance >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D7377), AppColors.accentStart, Color(0xFF00C6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentStart.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const DetailedSummaryDialog(),
            );
          },
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -30,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  children: [
                    // Label row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Gerçek Net Bakiye',
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.info_outline_rounded, color: Colors.white38, size: 13),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Main balance
                    Text(
                      Formatters.formatCurrency(netBalance),
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Divider
                    Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                    const SizedBox(height: 20),
                    // Assets / Debts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(
                          'Varlıklar',
                          assets,
                          Icons.account_balance_rounded,
                          AppColors.success,
                        ),
                        Container(
                          width: 1,
                          height: 44,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        _buildStat(
                          'Borçlar',
                          debts,
                          Icons.credit_card_rounded,
                          const Color(0xFFFF7B7B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, double amount, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.formatCurrency(amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
