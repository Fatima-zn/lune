import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../providers/listen_notes_api_provider.dart';
import '../../../providers/storage_provider.dart';
import '../../auth/providers/auth_provider.dart';

// Best podcasts from API
final bestPodcastsProvider = FutureProvider.family<BestPodcastsResponse, int>((ref, genreId) async {
  final api = ref.watch(listenNotesApiProvider);
  return api.getBestPodcasts(genreId: genreId);
});

// User profile from Firestore
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUserProfile();
});

// Recently played from local storage
final recentlyPlayedProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  try {
    return await storage.getRecentlyPlayed();
  } catch (e) {
    // Return empty list if storage isn't initialized yet
    return [];
  }
});


// Sync favorites from Firestore when user logs in
final syncFavoritesProvider = FutureProvider<void>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  await storage.syncFavoritesFromFirestore();
});