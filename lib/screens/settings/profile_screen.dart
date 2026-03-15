import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  List<Map<String, dynamic>> _sharedUsers = [];
  bool _isLoading = true;
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSharedUsers();
  }

  Future<void> _loadSharedUsers() async {
    setState(() => _isLoading = true);
    try {
      final demo = ref.read(demoServiceProvider);
      final users = await demo.getSharedUsers();
      if (mounted) setState(() => _sharedUsers = users);
    } catch (_) {
      if (mounted) setState(() => _sharedUsers = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _inviteUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    try {
      final demo = ref.read(demoServiceProvider);
      await demo.addSharedUser(email);
      _emailController.clear();
      await _loadSharedUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı davet edildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil ve Erişim'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentStart, AppColors.accentEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Demo Kullanıcı',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'demo@netbakiye.app',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Paylaşılan Kullanıcılar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Bu hesaba erişebilen diğer kullanıcılar.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'E-posta adresi girin',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _inviteUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentStart,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.person_add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_sharedUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                child: const Column(
                  children: [
                    Icon(Icons.group_outlined, size: 40, color: AppColors.textMuted),
                    SizedBox(height: 8),
                    Text('Henüz paylaşılan kullanıcı yok', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                    SizedBox(height: 4),
                    Text('Yukarıdan e-posta ile davet gönderebilirsiniz.', style: TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              )
            else
              ...(_sharedUsers.map((sharedUser) {
                final profile = sharedUser['profiles'];
                final displayName = profile?['display_name'] ?? '?';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.card,
                        radius: 20,
                        child: Text(displayName.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(displayName, style: const TextStyle(color: Colors.white))),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 20),
                        onPressed: () async {
                          final id = sharedUser['id']?.toString();
                          if (id == null) return;
                          final demo = ref.read(demoServiceProvider);
                          await demo.removeSharedUser(id);
                          await _loadSharedUsers();
                        },
                      ),
                    ],
                  ),
                );
              })),
          ],
        ),
      ),
    );
  }
}
