import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../../../core/widgets/podcast_card_vertical.dart';

class BestPodcastsSection extends ConsumerWidget {
  const BestPodcastsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestPodcastsAsync = ref.watch(bestPodcastsProvider(0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Best Podcasts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        bestPodcastsAsync.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load podcasts',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(bestPodcastsProvider(0)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (response) {
            final podcasts = response.podcasts;
            if (podcasts.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(child: Text('No podcasts found')),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: podcasts.length,
              itemBuilder: (context, index) {
                return PodcastCardVertical(podcast: podcasts[index]);
              },
            );
          },
        ),
      ],
    );
  }
}