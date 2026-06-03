import 'episode_podcast_info.dart';

class Episode {
  final String id;
  final String? rss;
  final String? link;
  final String? audio;
  final String? image;
  final int? itunesId;
  final String? thumbnail;
  final int? pubDateMs;
  final String title;
  final String? listennotesUrl;
  final int? audioLengthSec;
  final bool? explicitContent;
  final String? description;
  final String? titleHighlighted;
  final String? descriptionHighlighted;
  final List<String>? transcriptsHighlighted;
  final EpisodePodcastInfo? podcast;
  final String? transcript;
  final bool? maybeAudioInvalid;
  final String? listennotesEditUrl;

  const Episode({
    required this.id,
    this.rss,
    this.link,
    this.audio,
    this.image,
    this.itunesId,
    this.thumbnail,
    this.pubDateMs,
    required this.title,
    this.listennotesUrl,
    this.audioLengthSec,
    this.explicitContent,
    this.description,
    this.titleHighlighted,
    this.descriptionHighlighted,
    this.transcriptsHighlighted,
    this.podcast,
    this.transcript,
    this.maybeAudioInvalid,
    this.listennotesEditUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'].toString(),
      rss: json['rss'] as String?,
      link: json['link'] as String?,
      audio: json['audio'] as String?,
      image: json['image'] as String?,
      itunesId: _parseInt(json['itunes_id']),
      thumbnail: json['thumbnail'] as String?,
      pubDateMs: _parseInt(json['pub_date_ms']),
      title: (json['title_original'] ?? json['title']) as String? ?? '',
      listennotesUrl: json['listennotes_url'] as String?,
      audioLengthSec: _parseInt(json['audio_length_sec']),
      explicitContent: json['explicit_content'] as bool?,
      description: json['description_original'] as String? ?? json['description'] as String?,
      titleHighlighted: json['title_highlighted'] as String?,
      descriptionHighlighted: json['description_highlighted'] as String?,
      transcriptsHighlighted: (json['transcripts_highlighted'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      podcast: json['podcast'] != null
          ? EpisodePodcastInfo.fromJson(json['podcast'] as Map<String, dynamic>)
          : null,
      transcript: json['transcript'] as String?,
      maybeAudioInvalid: json['maybe_audio_invalid'] as bool?,
      listennotesEditUrl: json['listennotes_edit_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (rss != null) 'rss': rss,
      if (link != null) 'link': link,
      if (audio != null) 'audio': audio,
      if (image != null) 'image': image,
      if (itunesId != null) 'itunes_id': itunesId,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (pubDateMs != null) 'pub_date_ms': pubDateMs,
      'title': title,
      if (listennotesUrl != null) 'listennotes_url': listennotesUrl,
      if (audioLengthSec != null) 'audio_length_sec': audioLengthSec,
      if (explicitContent != null) 'explicit_content': explicitContent,
      if (description != null) 'description': description,
      if (titleHighlighted != null) 'title_highlighted': titleHighlighted,
      if (descriptionHighlighted != null) 'description_highlighted': descriptionHighlighted,
      if (transcriptsHighlighted != null) 'transcripts_highlighted': transcriptsHighlighted,
      if (podcast != null) 'podcast': podcast!.toJson(),
      if (transcript != null) 'transcript': transcript,
      if (maybeAudioInvalid != null) 'maybe_audio_invalid': maybeAudioInvalid,
      if (listennotesEditUrl != null) 'listennotes_edit_url': listennotesEditUrl,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Helper getters
  String get imageUrl => image ?? thumbnail ?? podcast?.image ?? '';
  String get podcastTitle => podcast?.title ?? 'Unknown Podcast';
  Duration get duration => Duration(seconds: audioLengthSec ?? 0);
  DateTime? get publishDate => pubDateMs != null
      ? DateTime.fromMillisecondsSinceEpoch(pubDateMs!)
      : null;
}