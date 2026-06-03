import 'podcast.dart';

class BestPodcastsResponse {
  final int id;
  final String name;
  final int? parentId;
  final int total;
  final bool hasNext;
  final List<Podcast> podcasts;
  final int pageNumber;
  final bool hasPrevious;
  final String? listennotesUrl;
  final int? nextPageNumber;
  final int? previousPageNumber;

  const BestPodcastsResponse({
    required this.id,
    required this.name,
    this.parentId,
    required this.total,
    required this.hasNext,
    required this.podcasts,
    required this.pageNumber,
    required this.hasPrevious,
    this.listennotesUrl,
    this.nextPageNumber,
    this.previousPageNumber,
  });

  factory BestPodcastsResponse.fromJson(Map<String, dynamic> json) {
    return BestPodcastsResponse(
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      parentId: _parseInt(json['parent_id']),
      total: _parseInt(json['total']) ?? 0,
      hasNext: json['has_next'] as bool? ?? false,
      podcasts: (json['podcasts'] as List<dynamic>?)
              ?.map((e) => Podcast.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      pageNumber: _parseInt(json['page_number']) ?? 1,
      hasPrevious: json['has_previous'] as bool? ?? false,
      listennotesUrl: json['listennotes_url'] as String?,
      nextPageNumber: _parseInt(json['next_page_number']),
      previousPageNumber: _parseInt(json['previous_page_number']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (parentId != null) 'parent_id': parentId,
      'total': total,
      'has_next': hasNext,
      'podcasts': podcasts.map((p) => p.toJson()).toList(),
      'page_number': pageNumber,
      'has_previous': hasPrevious,
      if (listennotesUrl != null) 'listennotes_url': listennotesUrl,
      if (nextPageNumber != null) 'next_page_number': nextPageNumber,
      if (previousPageNumber != null) 'previous_page_number': previousPageNumber,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}