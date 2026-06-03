import 'package:flutter/material.dart';
import 'package:lune/core/theme/app_theme.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isRepeating;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipForward;
  final VoidCallback onSkipBackward;
  final VoidCallback onToggleRepeat;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isRepeating,
    required this.onPlayPause,
    required this.onSkipForward,
    required this.onSkipBackward,
    required this.onToggleRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Repeat button
        IconButton(
          iconSize: 24,
          icon: Icon(
            Icons.repeat,
            color: isRepeating ? AppColors.primary : AppColors.textPrimary,
          ),
          onPressed: onToggleRepeat,
        ),
        const SizedBox(width: 8),
        // Skip backward
        IconButton(
          iconSize: 40,
          icon: const Icon(Icons.replay_10),
          onPressed: onSkipBackward,
        ),
        const SizedBox(width: 16),
        // Play/Pause
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: IconButton(
            iconSize: 40,
            color: Colors.white,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: onPlayPause,
          ),
        ),
        const SizedBox(width: 16),
        // Skip forward
        IconButton(
          iconSize: 40,
          icon: const Icon(Icons.forward_30),
          onPressed: onSkipForward,
        ),
        const SizedBox(width: 8),
        // Placeholder to balance repeat button (keeps play centered)
        const SizedBox(width: 32),
      ],
    );
  }
}