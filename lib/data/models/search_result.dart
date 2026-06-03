import 'episode.dart';
import 'podcast.dart';
import 'curated_list.dart';

enum SearchResultType { episode, podcast, curated }

class SearchResult {
  final SearchResultType type;
  final Episode? episode;
  final Podcast? podcast;
  final CuratedList? curatedList;

  const SearchResult({
    required this.type,
    this.episode,
    this.podcast,
    this.curatedList,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    // ✅ FIXED: Better detection logic
    // Episode has 'audio' field or 'transcripts_highlighted'
    if (json['audio'] != null || json.containsKey('transcripts_highlighted')) {
      return SearchResult(
        type: SearchResultType.episode,
        episode: Episode.fromJson(json),
      );
    }
    // Curated list has 'source_domain' or 'source_url' field
    if (json['source_domain'] != null || json['source_url'] != null) {
      return SearchResult(
        type: SearchResultType.curated,
        curatedList: CuratedList.fromJson(json),
      );
    }
    // Otherwise it's a podcast
    return SearchResult(
      type: SearchResultType.podcast,
      podcast: Podcast.fromJson(json),
    );
  }
}

class SearchResponse {
  final double took;
  final int count;
  final int total;
  final List<SearchResult> results;
  final int? nextOffset;

  const SearchResponse({
    required this.took,
    required this.count,
    required this.total,
    required this.results,
    this.nextOffset,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      took: (json['took'] as num).toDouble(),
      count: json['count'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      nextOffset: json['next_offset'] as int?,
    );
  }
}