import 'podcast.dart';
import 'episode.dart';

class PodcastRecommendations {
  final List<Podcast> recommendations;

  const PodcastRecommendations({required this.recommendations});

  factory PodcastRecommendations.fromJson(Map<String, dynamic> json) {
    return PodcastRecommendations(
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => Podcast.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
}

class EpisodeRecommendations {
  final List<Episode> recommendations;

  const EpisodeRecommendations({required this.recommendations});

  factory EpisodeRecommendations.fromJson(Map<String, dynamic> json) {
    return EpisodeRecommendations(
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
}