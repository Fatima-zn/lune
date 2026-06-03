import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/search_result.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult result;

  const SearchResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.type == SearchResultType.episode && result.episode != null) {
      return _EpisodeResult(episode: result.episode!);
    } else if (result.type == SearchResultType.podcast && result.podcast != null) {
      return _PodcastResult(podcast: result.podcast!);
    }
    return const SizedBox.shrink();
  }
}

class _EpisodeResult extends StatelessWidget {
  final dynamic episode;

  const _EpisodeResult({required this.episode});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          episode.imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 56,
            height: 56,
            color: Colors.grey[300],
            child: const Icon(Icons.music_note, color: Colors.grey),
          ),
        ),
      ),
      title: Text(
        episode.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        episode.podcastTitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      onTap: () {
        context.push('/player', extra: {
          'id': episode.id,
          'title': episode.title,
          'audio': episode.audio,
          'image': episode.imageUrl,
          'podcastTitle': episode.podcastTitle,
        });
      },
    );
  }
}

class _PodcastResult extends StatelessWidget {
  final dynamic podcast;

  const _PodcastResult({required this.podcast});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          podcast.imageUrl,
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
        podcast.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        podcast.publisher,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      onTap: () {
        context.push('/podcast/${podcast.id}');
      },
    );
  }
}