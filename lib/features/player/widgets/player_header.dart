import 'package:flutter/material.dart';

class PlayerHeader extends StatelessWidget {
  final String? podcastTitle;
  final VoidCallback onDismiss;

  const PlayerHeader({
    super.key,
    this.podcastTitle,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: onDismiss,
          ),
          Expanded(
            child: Text(
              podcastTitle ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}