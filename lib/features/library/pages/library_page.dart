import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/library_provider.dart';
import '../../../providers/storage_provider.dart';
import '../../../data/services/local/biometric_service.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(favoritesProvider, (_, __) {});
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load favorites')),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final podcast = favorites[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    podcast['image'] as String? ?? '',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[300],
                      child: const Icon(Icons.podcasts, color: Colors.grey),
                    ),
                  ),
                ),
                title: Text(
                  podcast['title'] as String? ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  podcast['publisher'] as String? ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove Favorite?'),
                        content: const Text('Biometric authentication is required to remove this podcast from favorites.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Authenticate'),
                            onPressed: () async {
                              Navigator.pop(ctx, true);
                            },
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true) {
                      // Perform biometric authentication
                      final biometricService = BiometricService();
                      final isAuthenticated = await biometricService.authenticateWithBiometrics();
                      
                      if (isAuthenticated && context.mounted) {
                        final storage = ref.read(storageServiceProvider);
                        await storage.toggleFavorite(
                          podcast['id'] as String,
                          podcast,
                        );
                        ref.invalidate(favoritesProvider);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Removed from favorites')),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Authentication failed')),
                        );
                      }
                    }
                  },
                ),
                onTap: () {
                  context.push('/podcast/${podcast['id']}');
                },
              );
            },
          );
        },
      ),
    );
  }
}