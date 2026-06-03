import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/search_result.dart';
import '../../../data/models/genre.dart';
import '../../../providers/listen_notes_api_provider.dart';

// Search query state - use NotifierProvider with a simple notifier
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  () => SearchQueryNotifier(),
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }
}

// Search results
final searchResultsProvider = FutureProvider.family<SearchResponse, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return SearchResponse(took: 0, count: 0, total: 0, results: []);
  }
  final api = ref.watch(listenNotesApiProvider);
  return api.search(query: query);
});

// Genres/Categories
final genresProvider = FutureProvider<List<Genre>>((ref) async {
  final api = ref.watch(listenNotesApiProvider);
  return api.getGenres();
});

// Trending searches
final trendingSearchesProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(listenNotesApiProvider);
  return api.getTrendingSearches();
});