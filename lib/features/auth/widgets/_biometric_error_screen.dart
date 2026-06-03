import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import '../providers/biometric_provider.dart';
import '../providers/auth_provider.dart';

class BiometricErrorScreen extends ConsumerWidget {
  final String? message;
  final bool allowRetry;

  const BiometricErrorScreen({
    super.key,
    this.message,
    this.allowRetry = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Required'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint_rounded,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication Failed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'Biometric authentication is required to use this app.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (allowRetry) ...[
                // Retry button - invalidates provider to re-trigger biometric
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(biometricProvider);
                  },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    minimumSize: const Size(200, 48),
                  ),
                ),
                const SizedBox(height: 16),
                // Logout button
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authServiceProvider).logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    minimumSize: const Size(200, 48),
                  ),
                ),
              ] else ...[
                // If retry not allowed, show restart button
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(biometricProvider);
                    ref.invalidate(authStateProvider);
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart App'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    minimumSize: const Size(200, 48),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}