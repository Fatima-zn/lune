import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/podcast_detail.dart';
import '../../../data/models/podcast.dart';
import '../../../providers/listen_notes_api_provider.dart';

// Podcast detail with episodes
final podcastDetailProvider = FutureProvider.family<PodcastDetail, String>((ref, podcastId) async {
  final api = ref.watch(listenNotesApiProvider);
  return api.getPodcastById(podcastId);
});

// Podcast recommendations
final podcastRecommendationsProvider = FutureProvider.family<List<Podcast>, String>((ref, podcastId) async {
  final api = ref.watch(listenNotesApiProvider);
  return api.getPodcastRecommendations(podcastId);
});