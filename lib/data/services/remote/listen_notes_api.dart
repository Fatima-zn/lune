import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../../../core/config/app_config.dart';

class ListenNotesApiException implements Exception {
  final String message;
  final int? statusCode;

  const ListenNotesApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ListenNotesApiException: $message';
}

class ListenNotesApi {
  final http.Client _client;

  ListenNotesApi({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'X-ListenAPI-Key': AppConfig.listenNotesApiKey,
        'Accept': 'application/json',
      };

  // Helper method for GET requests
  Future<Map<String, dynamic>> _get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${AppConfig.listenNotesBaseUrl}$endpoint').replace(
      queryParameters: queryParams,
    );

    print('🔍 API Call: $uri');
    print('🔍 Headers: ${_headers.toString().replaceAll(AppConfig.listenNotesApiKey, 'HIDDEN')}');

    try {
      final response = await _client.get(uri, headers: _headers);
      
      print('🔍 Response Status: ${response.statusCode}');
      print('🔍 Response Body (first 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw ListenNotesApiException('Invalid API key. Check your key in AppConfig.', statusCode: 401);
      } else if (response.statusCode == 429) {
        throw ListenNotesApiException('Rate limit exceeded. You may be on the FREE plan with limited requests.', statusCode: 429);
      } else {
        throw ListenNotesApiException(
          'API request failed with status ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on ListenNotesApiException {
      rethrow;
    } catch (e) {
      print('❌ Network error: $e');
      throw ListenNotesApiException('Network error: ${e.toString()}');
    }
  }
  // ==================== Search Endpoints ====================

  /// Full-text search on episodes, podcasts, or curated lists
  /// [q] - Search query
  /// [type] - Type of results: 'episode', 'podcast', or 'curated'
  /// [offset] - Pagination offset (max 30 for FREE plan)
  /// [language] - Filter by language (e.g., 'English')
  /// [genreIds] - Filter by genre IDs
  Future<SearchResponse> search({
    required String query,
    String? type,
    int? offset,
    String? language,
    List<int>? genreIds,
    bool? onlyIn,
  }) async {
    final params = <String, String>{
      'q': query,
    };
    if (type != null) params['type'] = type;
    if (offset != null) params['offset'] = offset.toString();
    if (language != null) params['language'] = language;
    if (genreIds != null && genreIds.isNotEmpty) {
      params['genre_ids'] = genreIds.join(',');
    }
    if (onlyIn != null) params['only_in'] = onlyIn.toString();

    final json = await _get('/search', queryParams: params);
    return SearchResponse.fromJson(json);
  }

  /// Search episode titles only (more focused results)
  Future<SearchResponse> searchEpisodeTitles({
    required String query,
    String? podcastId,
    int? offset,
  }) async {
    final params = <String, String>{
      'q': query,
    };
    if (podcastId != null) params['podcast_id'] = podcastId;
    if (offset != null) params['offset'] = offset.toString();

    final json = await _get('/search_episode_titles', queryParams: params);
    return SearchResponse.fromJson(json);
  }

  /// Fetch trending search terms
  Future<List<String>> getTrendingSearches() async {
    final json = await _get('/trending_searches');
    final terms = json['terms'] as List<dynamic>?;
    return terms?.map((e) => e as String).toList() ?? [];
  }

  // ==================== Podcast Endpoints ====================

  /// Fetch detailed meta data and episodes for a podcast
  /// [nextEpisodePubDate] - Pagination timestamp for next page of episodes
  Future<PodcastDetail> getPodcastById(
    String id, {
    int? nextEpisodePubDate,
  }) async {
    final params = <String, String>{};
    if (nextEpisodePubDate != null) {
      params['next_episode_pub_date'] = nextEpisodePubDate.toString();
    }

    final json = await _get('/podcasts/$id', queryParams: params);
    return PodcastDetail.fromJson(json);
  }

  /// Fetch recommendations for a podcast (up to 8 podcasts)
  Future<List<Podcast>> getPodcastRecommendations(String id) async {
    final json = await _get('/podcasts/$id/recommendations');
    final recommendations = PodcastRecommendations.fromJson(json);
    return recommendations.recommendations;
  }

  /// Fetch best podcasts by genre
  /// [genreId] - Genre ID from /genres endpoint (use '0' for all genres)
  /// [page] - Page number for pagination
  Future<BestPodcastsResponse> getBestPodcasts({
    int genreId = 0,
    int? page,
  }) async {
    final params = <String, String>{};
    if (genreId != 0) params['genre_id'] = genreId.toString();
    if (page != null) params['page'] = page.toString();

    final json = await _get('/best_podcasts', queryParams: params);
    return BestPodcastsResponse.fromJson(json);
  }

  // ==================== Episode Endpoints ====================

  /// Fetch detailed meta data for an episode
  Future<Episode> getEpisodeById(String id) async {
    final json = await _get('/episodes/$id');
    return Episode.fromJson(json);
  }

  /// Fetch recommendations for an episode (up to 8 episodes)
  Future<List<Episode>> getEpisodeRecommendations(String id) async {
    final json = await _get('/episodes/$id/recommendations');
    final recommendations = EpisodeRecommendations.fromJson(json);
    return recommendations.recommendations;
  }

  /// Fetch a random podcast episode
  Future<Episode> getRandomEpisode() async {
    final json = await _get('/just_listen');
    return Episode.fromJson(json);
  }

  // ==================== Genre Endpoints ====================

  /// Fetch list of podcast genres
  Future<List<Genre>> getGenres() async {
    final json = await _get('/genres');
    final response = GenresResponse.fromJson(json);
    return response.genres;
  }

  // ==================== Curated List Endpoints ====================

  /// Fetch curated lists of podcasts
  Future<CuratedListsResponse> getCuratedLists({int? page}) async {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();

    final json = await _get('/curated_podcasts', queryParams: params);
    return CuratedListsResponse.fromJson(json);
  }

  /// Dispose the HTTP client when done
  void dispose() {
    _client.close();
  }
}