import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/features/movies/presentation/providers/movie_repository_provider.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

final FutureProvider<List<Movie>> popularMoviesProvider =
    FutureProvider<List<Movie>>((Ref ref) async {
      final MovieRepository repository = ref.watch(movieRepositoryProvider);
      final Result<PagedResult<Movie>> result = await repository.getPopular();
      return switch (result) {
        Success<PagedResult<Movie>>(data: final PagedResult<Movie> paged) =>
          paged.results,
        FailureResult<PagedResult<Movie>>(failure: final Failure failure) =>
          throw failure,
      };
    });
