import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/genre.dart';
import '../theme/app_theme.dart';

class GenreCard extends StatelessWidget {
  final Genre genre;

  const GenreCard({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/genre/${genre.id}', extra: genre.name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                _getIcon(genre.id),
                color: Colors.black,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              genre.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(int id) {
    const icons = [
      Icons.mic,
      Icons.headphones,
      Icons.school,
      Icons.psychology,
      Icons.music_note,
      Icons.lightbulb,
      Icons.favorite,
      Icons.trending_up,
    ];
    return icons[id % icons.length];
  }
}