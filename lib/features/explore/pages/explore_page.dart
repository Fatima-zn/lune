import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lune/core/theme/app_theme.dart';
import '../providers/explore_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_result_card.dart';
import '../../../core/widgets/genre_card.dart';


class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final isSearching = searchQuery.trim().isNotEmpty;

    return PopScope(
      canPop: !isSearching,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isSearching) {
          ref.read(searchQueryProvider.notifier).update('');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const ExploreSearchBar(),
              Expanded(
                child: isSearching
                    ? _buildSearchResults(ref, searchQuery)
                    : _buildBrowseView(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseView(WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendingSearches(ref),
          const SizedBox(height: 16),
          _buildGenresGrid(ref),
        ],
      ),
    );
  }

  Widget _buildTrendingSearches(WidgetRef ref) {
    final trendingAsync = ref.watch(trendingSearchesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Trending Searches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        trendingAsync.when(
          loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (terms) {
            if (terms.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: terms.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(terms[index]),
                      backgroundColor: AppColors.primaryLight,
                      labelStyle: const TextStyle(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w500,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () {
                        ref.read(searchQueryProvider.notifier).update(terms[index]);
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGenresGrid(WidgetRef ref) {
    final genresAsync = ref.watch(genresProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Browse Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        genresAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(
            height: 60,
            child: Center(child: Text('Failed to load categories')),
          ),
          data: (genres) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  return GenreCard(genre: genres[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults(WidgetRef ref, String query) {
    final searchAsync = ref.watch(searchResultsProvider(query));

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Search failed')),
      data: (response) {
        if (response.results.isEmpty) {
          return const Center(child: Text('No results found'));
        }
        return ListView.builder(
          itemCount: response.results.length,
          itemBuilder: (context, index) {
            return SearchResultCard(result: response.results[index]);
          },
        );
      },
    );
  }
}