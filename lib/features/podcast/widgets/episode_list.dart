import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/episode.dart';
import '../../../core/theme/app_theme.dart';

class EpisodeList extends StatelessWidget {
  final List<Episode> episodes;
  final String podcastTitle;

  const EpisodeList({
    super.key,
    required this.episodes,
    required this.podcastTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: Text('No episodes found', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Episodes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            return _EpisodeTile(
              episode: episodes[index],
              podcastTitle: podcastTitle,
            );
          },
        ),
      ],
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final Episode episode;
  final String podcastTitle;

  const _EpisodeTile({required this.episode, required this.podcastTitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _playEpisode(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                episode.imageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 44,
                  height: 44,
                  color: AppColors.surfaceLight,
                  child: const Icon(Icons.music_note, size: 20, color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (episode.publishDate != null) ...[
                        Text(
                          _formatDate(episode.publishDate!),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _formatDuration(episode.duration),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 30),
          ],
        ),
      ),
    );
  }

  void _playEpisode(BuildContext context) {
    context.push('/player', extra: {
      'id': episode.id,
      'title': episode.title,
      'audio': episode.audio,
      'image': episode.imageUrl,
      'podcastTitle': podcastTitle,
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}