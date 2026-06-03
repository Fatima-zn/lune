import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/player/providers/player_provider.dart';
import '../theme/app_theme.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);

    if (playerState.title == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        context.push('/player');
      },
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: ClipOval(
                child: playerState.imageUrl != null
                    ? Image.network(
                        playerState.imageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44,
                          height: 44,
                          color: Colors.white.withValues(alpha: 0.2),
                          child: const Icon(Icons.podcasts, size: 24, color: Colors.white),
                        ),
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(Icons.podcasts, size: 24, color: Colors.white),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerState.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: playerState.duration.inMilliseconds > 0
                            ? playerState.position.inMilliseconds /
                                playerState.duration.inMilliseconds
                            : 0,
                        minHeight: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 32,
                color: Colors.white,
              ),
              onPressed: () {
                ref.read(playerStateProvider.notifier).togglePlayPause();
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.white),
              onPressed: () {
                ref.read(playerStateProvider.notifier).stop();
              },
            ),
          ],
        ),
      ),
    );
  }
}