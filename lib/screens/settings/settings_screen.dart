import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Renk Teması', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Uygulamanın aksent rengini seçin.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            _buildThemeSelector(ref, currentTheme),
            const SizedBox(height: 32),
            const Text('Hesap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Profil ve Erişim',
              subtitle: 'Kişisel bilgiler ve paylaşılan kullanıcılar',
              onTap: () => context.push('/settings/profile'),
            ),
            const SizedBox(height: 8),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Güvenlik',
              subtitle: 'Şifre ve oturum ayarları',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsTile(
              icon: Icons.calendar_today_outlined,
              title: 'Sabit Ödemeler',
              subtitle: 'Kira, fatura ve abonelikleri yönetin',
              onTap: () => context.push('/settings/fixed-payments'),
            ),
            const SizedBox(height: 32),
            const Text('Uygulama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'Hakkında',
              subtitle: 'NetBakiye v0.1.0',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo modunda çıkış yapılamaz')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger.withOpacity(0.1),
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(WidgetRef ref, String currentTheme) {
    final themes = AppColors.themePresets;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: themes.entries.map((entry) {
        final isSelected = currentTheme == entry.key;
        final colors = entry.value;
        final labels = {'teal': 'Teal', 'purple': 'Mor', 'blue': 'Mavi', 'orange': 'Turuncu', 'rose': 'Pembe'};
        final label = labels[entry.key] ?? entry.key;

        return GestureDetector(
          onTap: () => ref.read(themeColorProvider.notifier).state = entry.key,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: isSelected ? [BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 16, spreadRadius: 2)] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.textPrimary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
