import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lune/core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';
import '../widgets/player_header.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with dismiss button
            PlayerHeader(
              podcastTitle: playerState.podcastTitle ?? '',
              onDismiss: () => Navigator.pop(context),
            ),

            const Spacer(),

            // Podcast artwork
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: playerState.imageUrl != null
                    ? Image.network(
                        playerState.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceLight,
                          child: const Icon(Icons.podcasts, size: 80, color: AppColors.textMuted),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(Icons.podcasts, size: 80, color: AppColors.textMuted),
                      ),
              ),
            ),

            const SizedBox(height: 40),

            // Episode title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                playerState.title ?? 'No track selected',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Podcast name
            if (playerState.podcastTitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  playerState.podcastTitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ProgressBar(
                position: playerState.position,
                duration: playerState.duration,
                onSeek: (position) {
                  ref.read(playerStateProvider.notifier).seek(position);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Playback controls
            PlayerControls(
              isPlaying: playerState.isPlaying,
              isRepeating: playerState.isRepeating,
              onPlayPause: () {
                ref.read(playerStateProvider.notifier).togglePlayPause();
              },
              onSkipForward: () {
                final newPos = playerState.position + const Duration(seconds: 30);
                ref.read(playerStateProvider.notifier).seek(newPos);
              },
              onSkipBackward: () {
                final newPos = playerState.position - const Duration(seconds: 15);
                ref.read(playerStateProvider.notifier).seek(newPos);
              },
              onToggleRepeat: () {
                ref.read(playerStateProvider.notifier).toggleRepeat();
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
