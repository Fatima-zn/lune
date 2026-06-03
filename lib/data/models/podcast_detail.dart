import 'podcast.dart';
import 'podcast_extra.dart';
import 'looking_for.dart';
import 'episode.dart';

class PodcastDetail extends Podcast {
  final List<Episode> episodes;
  final int? nextEpisodePubDate;

  const PodcastDetail({
    required super.id,
    required super.title,
    required super.publisher,
    required super.genreIds,
    super.rss,
    super.type,
    super.email,
    super.extra,
    super.image,
    super.country,
    super.website,
    super.language,
    super.itunesId,
    super.thumbnail,
    super.isClaimed,
    super.description,
    super.lookingFor,
    super.hasSponsors,
    super.listenScore,
    super.totalEpisodes,
    super.listennotesUrl,
    super.audioLengthSec,
    super.explicitContent,
    super.latestEpisodeId,
    super.latestPubDateMs,
    super.earliestPubDateMs,
    super.hasGuestInterviews,
    super.updateFrequencyHours,
    super.listenScoreGlobalRank,
    required this.episodes,
    this.nextEpisodePubDate,
  });

  factory PodcastDetail.fromJson(Map<String, dynamic> json) {
    return PodcastDetail(
      id: json['id'].toString(),
      title: (json['title_original'] ?? json['title']) as String? ?? '',
      publisher: (json['publisher_original'] ?? json['publisher']) as String? ?? 'Unknown',
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => _parseInt(e) ?? 0)
              .toList() ?? [],
      rss: json['rss'] as String?,
      type: json['type'] as String?,
      email: json['email'] as String?,
      extra: json['extra'] != null
          ? PodcastExtra.fromJson(json['extra'] as Map<String, dynamic>)
          : null,
      image: json['image'] as String?,
      country: json['country'] as String?,
      website: json['website'] as String?,
      language: json['language'] as String?,
      itunesId: _parseInt(json['itunes_id']),
      thumbnail: json['thumbnail'] as String?,
      isClaimed: json['is_claimed'] as bool?,
      description: json['description_original'] as String? ?? json['description'] as String?,
      lookingFor: json['looking_for'] != null
          ? LookingFor.fromJson(json['looking_for'] as Map<String, dynamic>)
          : null,
      hasSponsors: json['has_sponsors'] as bool?,
      listenScore: _parseInt(json['listen_score']),
      totalEpisodes: _parseInt(json['total_episodes']),
      listennotesUrl: json['listennotes_url'] as String?,
      audioLengthSec: _parseInt(json['audio_length_sec']),
      explicitContent: json['explicit_content'] as bool?,
      latestEpisodeId: json['latest_episode_id'] as String?,
      latestPubDateMs: _parseInt(json['latest_pub_date_ms']),
      earliestPubDateMs: _parseInt(json['earliest_pub_date_ms']),
      hasGuestInterviews: json['has_guest_interviews'] as bool?,
      updateFrequencyHours: _parseInt(json['update_frequency_hours']),
      listenScoreGlobalRank: json['listen_score_global_rank'] as String?,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      nextEpisodePubDate: _parseInt(json['next_episode_pub_date']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}