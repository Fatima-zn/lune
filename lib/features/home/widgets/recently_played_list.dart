import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_provider.dart';
import '../../../../core/theme/app_theme.dart';

class RecentlyPlayedList extends ConsumerWidget {
  const RecentlyPlayedList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayedAsync = ref.watch(recentlyPlayedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recently Played',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        recentlyPlayedAsync.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(
            height: 50,
            child: Center(child: Text('Could not load recent podcasts', style: TextStyle(fontSize: 12))),
          ),
          data: (recent) {
            if (recent.isEmpty) {
              return const SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    'No podcasts played yet',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 120, // Increased from 96
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recent.length,
                itemBuilder: (context, index) {
                  final episode = recent[index];
                  return GestureDetector(
                    onTap: () {
                      context.push('/player', extra: {
                        'id': episode['id'],
                        'title': episode['title'],
                        'audio': episode['audio'],
                        'image': episode['image'],
                        'podcastTitle': episode['podcastTitle'],
                      });
                    },
                    child: Container(
                      width: 72,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: Image.network(
                              episode['image'] as String? ?? '',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 72,
                                height: 72,
                                color: AppColors.surfaceLight,
                                child: const Icon(Icons.play_circle_outline, size: 24, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 28, // Fixed height for text
                            child: Text(
                              episode['title'] as String? ?? 'Unknown',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}