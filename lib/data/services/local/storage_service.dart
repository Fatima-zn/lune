import 'dart:convert';
import 'package:lune/data/models/listening_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Recently played episodes
  static const String _recentlyPlayedKey = 'recently_played';

  Future<void> addRecentlyPlayed(Map<String, dynamic> episodeData) async {
    final recent = await getRecentlyPlayed();

    // Remove if already exists (match by title or id)
    recent.removeWhere((e) =>
        e['title'] == episodeData['title'] || e['id'] == episodeData['id']);

    // Add to beginning
    recent.insert(0, episodeData);

    // Keep only last 20
    if (recent.length > 20) {
      recent.removeRange(20, recent.length);
    }

    await _prefs.setString(_recentlyPlayedKey, json.encode(recent));
  }

  Future<List<Map<String, dynamic>>> getRecentlyPlayed() async {
    final data = _prefs.getString(_recentlyPlayedKey);
    if (data == null) return [];

    final list = json.decode(data) as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  // Favorites
  static const String _favoritesKey = 'favorites';

  Future<void> toggleFavorite(
      String podcastId, Map<String, dynamic> podcastData) async {
    final favorites = await getFavorites();
    final isCurrentlyFav = favorites.any((e) => e['id'] == podcastId);

    // Local storage
    if (isCurrentlyFav) {
      favorites.removeWhere((e) => e['id'] == podcastId);
    } else {
      favorites.add(podcastData);
    }
    await _prefs.setString(_favoritesKey, json.encode(favorites));

    // Firestore sync
    _syncFavoriteToFirestore(podcastId, podcastData, !isCurrentlyFav);
  }

  void _syncFavoriteToFirestore(
      String podcastId, Map<String, dynamic> podcastData, bool isAdding) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .doc(podcastId);

    if (isAdding) {
      docRef.set({
        'id': podcastData['id'] ?? podcastId,
        'title': podcastData['title'] ?? '',
        'image': podcastData['image'] ?? '',
        'publisher': podcastData['publisher'] ?? '',
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      docRef.delete();
    }
  }

  Future<void> syncFavoritesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("favorites")
          .orderBy('addedAt', descending: true)
          .get();

      final cloudFavorites = snapshot.docs.map((doc) => doc.data()).toList();

      if (cloudFavorites.isNotEmpty) {
        final localFavorites = await getFavorites();
        final localIds = localFavorites.map((e) => e['id']).toSet();

        for (final cloud in cloudFavorites) {
          if (!localIds.contains(cloud['id'])) {
            localFavorites.add(cloud);
          }
        }

        await _prefs.setString(_favoritesKey, json.encode(localFavorites));
      }
    } catch (e) {
      // Offline - use local only
    }
  }

  Future<bool> isFavorite(String podcastId) async {
    final favorites = await getFavorites();
    return favorites.any((e) => e['id'] == podcastId);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final data = _prefs.getString(_favoritesKey);
    if (data == null) return [];

    final list = json.decode(data) as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  // Total favorites count
  Future<int> getTotalFavorites() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  //Stats
  static const String _totalListeningKey = 'total_listening_seconds';
  static const String _episodesCompletedKey = 'episodes_completed';
  static const String _streakKey = 'current_streak';
  static const String _lastListenDateKey = 'last_listen_date';

  Future<void> addListeningTime(
      int seconds, String podcastTitle, String? imageUrl) async {
    // Total time
    final total = _prefs.getInt(_totalListeningKey) ?? 0;
    await _prefs.setInt(_totalListeningKey, total + seconds);

    // Update streak
    final today = DateTime.now();
    final lastDateStr = _prefs.getString(_lastListenDateKey);
    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final diff = today.difference(lastDate).inDays;
      if (diff == 0) {
        // Same day, no change
      } else if (diff == 1) {
        // Consecutive day
        final streak = _prefs.getInt(_streakKey) ?? 0;
        await _prefs.setInt(_streakKey, streak + 1);
      } else {
        // Streak broken
        await _prefs.setInt(_streakKey, 1);
      }
    } else {
      await _prefs.setInt(_streakKey, 1);
    }
    await _prefs.setString(
        _lastListenDateKey, today.toIso8601String().split('T')[0]);

    // Track per-podcast stats
    await _updatePodcastStat(podcastTitle, imageUrl, seconds);
  }

  Future<void> _updatePodcastStat(
      String title, String? imageUrl, int seconds) async {
    const key = 'podcast_stats';
    final data = _prefs.getString(key);
    List<Map<String, dynamic>> stats = [];
    if (data != null) {
      stats = (json.decode(data) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }

    final index = stats.indexWhere((e) => e['title'] == title);
    if (index >= 0) {
      stats[index]['seconds'] =
          (stats[index]['seconds'] as int? ?? 0) + seconds;
      stats[index]['count'] = (stats[index]['count'] as int? ?? 0) + 1;
    } else {
      stats.add({
        'title': title,
        'imageUrl': imageUrl ?? '',
        'seconds': seconds,
        'count': 1,
      });
    }

    await _prefs.setString(key, json.encode(stats));
  }

  Future<void> incrementEpisodesCompleted() async {
    final count = _prefs.getInt(_episodesCompletedKey) ?? 0;
    await _prefs.setInt(_episodesCompletedKey, count + 1);
  }

  Future<ListeningStats> getListeningStats() async {
    final totalSeconds = _prefs.getInt(_totalListeningKey) ?? 0;
    final episodesCompleted = _prefs.getInt(_episodesCompletedKey) ?? 0;
    final streak = _prefs.getInt(_streakKey) ?? 0;

    // Get per-podcast stats
    final data = _prefs.getString('podcast_stats');
    List<PodcastStat> topPodcasts = [];
    if (data != null) {
      final list = (json.decode(data) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // Sort by seconds descending
      list.sort((a, b) => (b['seconds'] as int).compareTo(a['seconds'] as int));

      topPodcasts = list
          .take(5)
          .map((e) => PodcastStat(
                title: e['title'] as String? ?? '',
                imageUrl: e['imageUrl'] as String?,
                listeningTime: Duration(seconds: e['seconds'] as int? ?? 0),
                episodesPlayed: e['count'] as int? ?? 0,
              ))
          .toList();
    }

    return ListeningStats(
      totalListeningTime: Duration(seconds: totalSeconds),
      episodesCompleted: episodesCompleted,
      currentStreak: streak,
      topPodcasts: topPodcasts,
    );
  }

  // Monthly listening tracking (replace _weeklyListeningKey)
  static const String _monthlyListeningKey = 'monthly_listening';

  Future<void> addMonthlyListeningTime(int seconds) async {
    final today = DateTime.now();
    final dayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final data = _prefs.getString(_monthlyListeningKey);
    Map<String, dynamic> monthly = {};
    if (data != null) {
      monthly = Map<String, dynamic>.from(json.decode(data) as Map);
    }

    monthly[dayKey] = (monthly[dayKey] as int? ?? 0) + seconds;

    // Keep only current month
    final currentMonth =
        '${today.year}-${today.month.toString().padLeft(2, '0')}';
    monthly.removeWhere((key, _) => !key.startsWith(currentMonth));

    await _prefs.setString(_monthlyListeningKey, json.encode(monthly));
  }

  Future<Map<String, int>> getMonthlyListening() async {
    final data = _prefs.getString(_monthlyListeningKey);
    if (data == null) return {};

    final monthly = Map<String, dynamic>.from(json.decode(data) as Map);
    return monthly.map((key, value) => MapEntry(key, value as int));
  }

  // Listening goal (in hours)
  static const String _listeningGoalKey = 'listening_goal_hours';

  Future<void> setListeningGoal(int hours) async {
    await _prefs.setInt(_listeningGoalKey, hours);
  }

  Future<int> getListeningGoal() async {
    return _prefs.getInt(_listeningGoalKey) ?? 20;
  }

  Future<void> seedDemoData() async {
    final now = DateTime.now();

    // Build monthly data map
    final monthlyData = <String, int>{};
    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final randomSeconds = (20 + (i * 8) + (date.day % 7) * 12) * 60;
      monthlyData[dayKey] = randomSeconds;
    }
    await _prefs.setString(_monthlyListeningKey, json.encode(monthlyData));

    // Total listening time (~3.5 hours in seconds)
    await _prefs.setInt(_totalListeningKey, 12600);

    // Episodes completed
    await _prefs.setInt(_episodesCompletedKey, 12);

    // Streak
    await _prefs.setInt(_streakKey, 5);
    await _prefs.setString(
        _lastListenDateKey, now.toIso8601String().split('T')[0]);

  }
}
