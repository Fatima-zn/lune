import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/listening_stats.dart';
import '../../../providers/storage_provider.dart';

final listeningStatsProvider = FutureProvider<ListeningStats>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  
  final stats = await storage.getListeningStats();
  final monthly = await storage.getMonthlyListening();
  final favorites = await storage.getTotalFavorites();
  final goal = await storage.getListeningGoal();
  
  return ListeningStats(
    totalListeningTime: stats.totalListeningTime,
    episodesCompleted: stats.episodesCompleted,
    currentStreak: stats.currentStreak,
    topPodcasts: stats.topPodcasts,
    monthlyListening: monthly,
    totalFavorites: favorites,
    listeningGoalHours: goal,
  );
});

final listeningGoalProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getListeningGoal();
});