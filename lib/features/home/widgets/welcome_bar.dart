import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../data/services/local/biometric_service.dart';
import '../../../features/player/providers/player_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';




class WelcomeBar extends ConsumerWidget {
  const WelcomeBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final greeting = _getGreeting();

    return profileAsync.when(
      loading: () => _buildSkeleton(),
      error: (_, __) => _buildContent(context, greeting, 'Listener', ref),
      data: (profile) {
        final firstName = profile?['firstName'] as String? ?? 'Listener';
        return _buildContent(context, greeting, firstName, ref);
      },
    );
  }

  Widget _buildContent(BuildContext context, String greeting, String firstName, WidgetRef ref) {
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'L';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    children: [
                      TextSpan(text: '$greeting, '),
                      TextSpan(
                        text: firstName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Find your next listen',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted, size: 22),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Logout', style: TextStyle(color: AppColors.textPrimary)),
                  content: const Text('Biometric verification required to logout.', style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.fingerprint, size: 18),
                      label: const Text('Verify & Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && context.mounted) {
                final biometricService = BiometricService();
                final isAuthenticated = await biometricService.authenticateWithBiometrics();
                
                if (isAuthenticated && context.mounted) {
                  // Stop player
                  ref.read(playerStateProvider.notifier).stop();
                  
                  // Sign out from Firebase
                  await FirebaseAuth.instance.signOut();
                  
                  // Navigate to login route (outside shell, no bottom nav)
                  if (context.mounted) {
                    context.go('/login');
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Biometric verification failed'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLight,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 100, height: 12, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 6),
              Container(width: 60, height: 16, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}