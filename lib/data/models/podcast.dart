import 'podcast_extra.dart';
import 'looking_for.dart';

class Podcast {
  final String id;
  final String? rss;
  final String? type;
  final String? email;
  final PodcastExtra? extra;
  final String? image;
  final String title;
  final String? country;
  final String? website;
  final String? language;
  final List<int> genreIds;
  final int? itunesId;
  final String publisher;
  final String? thumbnail;
  final bool? isClaimed;
  final String? description;
  final LookingFor? lookingFor;
  final bool? hasSponsors;
  final int? listenScore;
  final int? totalEpisodes;
  final String? listennotesUrl;
  final int? audioLengthSec;
  final bool? explicitContent;
  final String? latestEpisodeId;
  final int? latestPubDateMs;
  final int? earliestPubDateMs;
  final bool? hasGuestInterviews;
  final int? updateFrequencyHours;
  final String? listenScoreGlobalRank;

  const Podcast({
    required this.id,
    this.rss,
    this.type,
    this.email,
    this.extra,
    this.image,
    required this.title,
    this.country,
    this.website,
    this.language,
    required this.genreIds,
    this.itunesId,
    required this.publisher,
    this.thumbnail,
    this.isClaimed,
    this.description,
    this.lookingFor,
    this.hasSponsors,
    this.listenScore,
    this.totalEpisodes,
    this.listennotesUrl,
    this.audioLengthSec,
    this.explicitContent,
    this.latestEpisodeId,
    this.latestPubDateMs,
    this.earliestPubDateMs,
    this.hasGuestInterviews,
    this.updateFrequencyHours,
    this.listenScoreGlobalRank,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'].toString(),
      rss: json['rss'] as String?,
      type: json['type'] as String?,
      email: json['email'] as String?,
      extra: json['extra'] != null
          ? PodcastExtra.fromJson(json['extra'] as Map<String, dynamic>)
          : null,
      image: json['image'] as String?,
      title: (json['title_original'] ?? json['title']) as String? ?? '',
      country: json['country'] as String?,
      website: json['website'] as String?,
      language: json['language'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => _parseInt(e) ?? 0)
              .toList() ??
          [],
      itunesId: _parseInt(json['itunes_id']),
      publisher: (json['publisher_original'] ?? json['publisher']) as String? ?? 'Unknown',
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (rss != null) 'rss': rss,
      if (type != null) 'type': type,
      if (email != null) 'email': email,
      if (extra != null) 'extra': extra!.toJson(),
      if (image != null) 'image': image,
      'title': title,
      if (country != null) 'country': country,
      if (website != null) 'website': website,
      if (language != null) 'language': language,
      'genre_ids': genreIds,
      if (itunesId != null) 'itunes_id': itunesId,
      'publisher': publisher,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (isClaimed != null) 'is_claimed': isClaimed,
      if (description != null) 'description': description,
      if (lookingFor != null) 'looking_for': lookingFor!.toJson(),
      if (hasSponsors != null) 'has_sponsors': hasSponsors,
      if (listenScore != null) 'listen_score': listenScore,
      if (totalEpisodes != null) 'total_episodes': totalEpisodes,
      if (listennotesUrl != null) 'listennotes_url': listennotesUrl,
      if (audioLengthSec != null) 'audio_length_sec': audioLengthSec,
      if (explicitContent != null) 'explicit_content': explicitContent,
      if (latestEpisodeId != null) 'latest_episode_id': latestEpisodeId,
      if (latestPubDateMs != null) 'latest_pub_date_ms': latestPubDateMs,
      if (earliestPubDateMs != null) 'earliest_pub_date_ms': earliestPubDateMs,
      if (hasGuestInterviews != null) 'has_guest_interviews': hasGuestInterviews,
      if (updateFrequencyHours != null) 'update_frequency_hours': updateFrequencyHours,
      if (listenScoreGlobalRank != null) 'listen_score_global_rank': listenScoreGlobalRank,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Helper getters
  String get imageUrl => image ?? thumbnail ?? '';
  int get episodeCount => totalEpisodes ?? 0;
  bool get hasHighResImage => image != null && image != thumbnail;
}