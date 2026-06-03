import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/podcast_card_vertical.dart';
import '../../../data/models/best_podcasts_res.dart';
import '../../../providers/listen_notes_api_provider.dart';

class GenrePodcastsPage extends ConsumerWidget {
  final int genreId;
  final String genreName;

  const GenrePodcastsPage({
    super.key,
    required this.genreId,
    required this.genreName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastsAsync = ref.watch(bestPodcastsByGenreProvider(genreId));

    return Scaffold(
      appBar: AppBar(
        title: Text(genreName),
      ),
      body: podcastsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load podcasts')),
        data: (response) {
          if (response.podcasts.isEmpty) {
            return const Center(child: Text('No podcasts found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: response.podcasts.length,
            itemBuilder: (context, index) {
              return PodcastCardVertical(podcast: response.podcasts[index]);
            },
          );
        },
      ),
    );
  }
}

final bestPodcastsByGenreProvider = FutureProvider.family<BestPodcastsResponse, int>((ref, genreId) async {
  final api = ref.watch(listenNotesApiProvider);
  return api.getBestPodcasts(genreId: genreId);
});