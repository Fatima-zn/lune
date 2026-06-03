class ListeningStats {
  final Duration totalListeningTime;
  final int episodesCompleted;
  final String topGenre;
  final int currentStreak;
  final Map<String, int> monthlyListening;
  final List<PodcastStat> topPodcasts;
  final int totalFavorites;
  final int listeningGoalHours;

  const ListeningStats({
    this.totalListeningTime = Duration.zero,
    this.episodesCompleted = 0,
    this.topGenre = 'None',
    this.currentStreak = 0,
    this.monthlyListening = const {},
    this.topPodcasts = const [],
    this.totalFavorites = 0,
    this.listeningGoalHours = 20,
  });
  
  Duration get monthlyTotal {
    final totalSeconds = monthlyListening.values.fold<int>(0, (sum, v) => sum + v);
    return Duration(seconds: totalSeconds);
  }
  
  double get goalProgress {
    final goalSeconds = listeningGoalHours * 3600;
    if (goalSeconds == 0) return 0;
    return (monthlyTotal.inSeconds / goalSeconds).clamp(0.0, 1.0);
  }
}

class PodcastStat {
  final String title;
  final String? imageUrl;
  final Duration listeningTime;
  final int episodesPlayed;

  const PodcastStat({
    required this.title,
    this.imageUrl,
    required this.listeningTime,
    required this.episodesPlayed,
  });
}