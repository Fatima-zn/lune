class EpisodePodcastInfo {
  final String id;
  final String? image;
  final List<int>? genreIds;
  final String? thumbnail;
  final int? listenScore;
  final String? title;
  final String? listennotesUrl;
  final String? publisher;
  final String? listenScoreGlobalRank;

  const EpisodePodcastInfo({
    required this.id,
    this.image,
    this.genreIds,
    this.thumbnail,
    this.listenScore,
    this.title,
    this.listennotesUrl,
    this.publisher,
    this.listenScoreGlobalRank,
  });

  factory EpisodePodcastInfo.fromJson(Map<String, dynamic> json) {
    return EpisodePodcastInfo(
      id: json['id'].toString(),
      image: json['image'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => _parseInt(e) ?? 0)
          .toList(),
      thumbnail: json['thumbnail'] as String?,
      listenScore: _parseInt(json['listen_score']),
      title: json['title_original'] as String? ?? json['title'] as String?,
      listennotesUrl: json['listennotes_url'] as String?,
      publisher: json['publisher_original'] as String? ?? json['publisher'] as String?,
      listenScoreGlobalRank: json['listen_score_global_rank'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (image != null) 'image': image,
      if (genreIds != null) 'genre_ids': genreIds,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (listenScore != null) 'listen_score': listenScore,
      if (title != null) 'title_original': title,
      if (listennotesUrl != null) 'listennotes_url': listennotesUrl,
      if (publisher != null) 'publisher_original': publisher,
      if (listenScoreGlobalRank != null) 'listen_score_global_rank': listenScoreGlobalRank,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}