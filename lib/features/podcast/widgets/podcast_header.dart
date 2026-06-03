import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/podcast_detail.dart';
import '../../../providers/storage_provider.dart';
import '../../../features/library/providers/library_provider.dart';
import '../../../core/theme/app_theme.dart';

class PodcastHeader extends ConsumerStatefulWidget {
  final PodcastDetail podcast;

  const PodcastHeader({super.key, required this.podcast});

  @override
  ConsumerState<PodcastHeader> createState() => _PodcastHeaderState();
}

class _PodcastHeaderState extends ConsumerState<PodcastHeader> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final storage = ref.read(storageServiceProvider);
    final isFav = await storage.isFavorite(widget.podcast.id);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    final storage = ref.read(storageServiceProvider);
    await storage.toggleFavorite(widget.podcast.id, {
      'id': widget.podcast.id,
      'title': widget.podcast.title,
      'image': widget.podcast.imageUrl,
      'publisher': widget.podcast.publisher,
    });
    ref.invalidate(favoritesProvider);
    if (mounted) {
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    final podcast = widget.podcast;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            podcast.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Publisher
          Row(
            children: [
              const Icon(Icons.person, size: 15, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  podcast.publisher,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          // Episode count
          Row(
            children: [
              const Icon(Icons.headphones, size: 15, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '${podcast.totalEpisodes ?? 0} episodes',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Like and Share buttons
          Row(
            children: [
              _ActionButton(
                icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: _isFavorite ? 'Saved' : 'Like',
                color: _isFavorite ? AppColors.error : AppColors.textMuted,
                onTap: _toggleFavorite,
              ),
              const SizedBox(width: 20),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                color: AppColors.textMuted,
                onTap: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'Check out "${podcast.title}" on ${podcast.listennotesUrl ?? ''}',
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // About section
          if (podcast.description != null) ...[
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _stripHtml(podcast.description!),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () {
                _showFullDescription(context, podcast.description!);
              },
              child: const Text(
                'Read more',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  void _showFullDescription(BuildContext context, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Text(
                _stripHtml(description),
                style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMuted),
              ),
            );
          },
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}