import 'podcast.dart';

class CuratedList {
  final String id;
  final String title;
  final int total;
  final List<Podcast> podcasts;
  final String? sourceUrl;
  final String? description;
  final int? pubDateMs;
  final String? sourceDomain;
  final String? listennotesUrl;
  final String? titleHighlighted;
  final String? descriptionHighlighted;

  const CuratedList({
    required this.id,
    required this.title,
    required this.total,
    required this.podcasts,
    this.sourceUrl,
    this.description,
    this.pubDateMs,
    this.sourceDomain,
    this.listennotesUrl,
    this.titleHighlighted,
    this.descriptionHighlighted,
  });

  factory CuratedList.fromJson(Map<String, dynamic> json) {
    return CuratedList(
      id: json['id'] as String,
      title: json['title_original'] as String? ?? json['title'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      podcasts: (json['podcasts'] as List<dynamic>?)
              ?.map((e) => Podcast.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      sourceUrl: json['source_url'] as String?,
      description: json['description_original'] as String? ?? json['description'] as String?,
      pubDateMs: json['pub_date_ms'] as int?,
      sourceDomain: json['source_domain'] as String?,
      listennotesUrl: json['listennotes_url'] as String?,
      titleHighlighted: json['title_highlighted'] as String?,
      descriptionHighlighted: json['description_highlighted'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'total': total,
      'podcasts': podcasts.map((p) => p.toJson()).toList(),
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (description != null) 'description': description,
      if (pubDateMs != null) 'pub_date_ms': pubDateMs,
      if (sourceDomain != null) 'source_domain': sourceDomain,
      if (listennotesUrl != null) 'listennotes_url': listennotesUrl,
      if (titleHighlighted != null) 'title_highlighted': titleHighlighted,
      if (descriptionHighlighted != null) 'description_highlighted': descriptionHighlighted,
    };
  }
}

class CuratedListsResponse {
  final int total;
  final bool hasNext;
  final int pageNumber;
  final bool hasPrevious;
  final List<CuratedList> curatedLists;
  final int? nextPageNumber;
  final int? previousPageNumber;

  const CuratedListsResponse({
    required this.total,
    required this.hasNext,
    required this.pageNumber,
    required this.hasPrevious,
    required this.curatedLists,
    this.nextPageNumber,
    this.previousPageNumber,
  });

  factory CuratedListsResponse.fromJson(Map<String, dynamic> json) {
    return CuratedListsResponse(
      total: json['total'] as int? ?? 0,
      hasNext: json['has_next'] as bool? ?? false,
      pageNumber: json['page_number'] as int? ?? 1,
      hasPrevious: json['has_previous'] as bool? ?? false,
      curatedLists: (json['curated_lists'] as List<dynamic>?)
              ?.map((e) => CuratedList.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      nextPageNumber: json['next_page_number'] as int?,
      previousPageNumber: json['previous_page_number'] as int?,
    );
  }
}