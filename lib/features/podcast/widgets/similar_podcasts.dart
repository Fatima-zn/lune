import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/podcast_detail_provider.dart';
import '../../../core/widgets/podcast_card.dart';
import '../../../core/theme/app_theme.dart';

class SimilarPodcasts extends ConsumerWidget {
  final String podcastId;

  const SimilarPodcasts({super.key, required this.podcastId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(podcastRecommendationsProvider(podcastId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Similar Podcasts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        recommendationsAsync.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(
            height: 60,
            child: Center(
              child: Text('Could not load recommendations', style: TextStyle(color: AppColors.textMuted)),
            ),
          ),
          data: (podcasts) {
            if (podcasts.isEmpty) {
              return const SizedBox(
                height: 60,
                child: Center(
                  child: Text('No recommendations', style: TextStyle(color: AppColors.textMuted)),
                ),
              );
            }
            return SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: podcasts.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 160,
                    child: PodcastCard(podcast: podcasts[index]),
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