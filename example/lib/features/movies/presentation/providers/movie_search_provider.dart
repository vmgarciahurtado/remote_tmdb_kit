import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/features/movies/presentation/providers/movie_repository_provider.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final NotifierProvider<SearchQueryNotifier, String> searchQueryProvider =
    NotifierProvider.autoDispose<SearchQueryNotifier, String>(
      SearchQueryNotifier.new,
    );

final FutureProvider<List<Movie>> movieSearchProvider =
    FutureProvider.autoDispose<List<Movie>>((Ref ref) async {
      final String query = ref.watch<String>(searchQueryProvider).trim();
      if (query.isEmpty) {
        return const <Movie>[];
      }

      final Completer<void> debounce = Completer<void>();
      final Timer timer = Timer(
        const Duration(milliseconds: 500),
        debounce.complete,
      );
      ref.onDispose(() {
        timer.cancel();
        if (!debounce.isCompleted) {
          debounce.completeError(StateError('search debounce cancelled'));
        }
      });
      await debounce.future;

      final MovieRepository repository = ref.watch(movieRepositoryProvider);
      final Result<PagedResult<Movie>> result = await repository.searchMovies(
        query,
      );
      return switch (result) {
        Success<PagedResult<Movie>>(data: final PagedResult<Movie> paged) =>
          paged.results,
        FailureResult<PagedResult<Movie>>(failure: final Failure failure) =>
          throw failure,
      };
    });
