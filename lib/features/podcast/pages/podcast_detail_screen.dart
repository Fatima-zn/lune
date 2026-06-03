import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/podcast_detail_provider.dart';
import '../widgets/podcast_header.dart';
import '../widgets/episode_list.dart';
import '../widgets/similar_podcasts.dart';
import '../../../core/widgets/_loading_screen.dart';
import '../../../core/widgets/_error_screen.dart';
import '../../../core/theme/app_theme.dart';

class PodcastDetailPage extends ConsumerWidget {
  final String podcastId;

  const PodcastDetailPage({super.key, required this.podcastId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastAsync = ref.watch(podcastDetailProvider(podcastId));

    return podcastAsync.when(
      loading: () => const LoadingScreen(message: 'Loading podcast...'),
      error: (error, stack) => ErrorScreen(
        message: error.toString(),
        onRetry: () => ref.invalidate(podcastDetailProvider(podcastId)),
      ),
      data: (podcast) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.background,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        podcast.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surfaceLight,
                            child: const Icon(Icons.podcasts, size: 80, color: AppColors.textMuted),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.background.withValues(alpha: 0.8),
                              AppColors.background.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.2, 0.5],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PodcastHeader(podcast: podcast),
                      const SizedBox(height: 24),
                      EpisodeList(episodes: podcast.episodes, podcastTitle: podcast.title),
                      const SizedBox(height: 8),
                      SimilarPodcasts(podcastId: podcastId),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          )
        );
      },
    );
  }
}