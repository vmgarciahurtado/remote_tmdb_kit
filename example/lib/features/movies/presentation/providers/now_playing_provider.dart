import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/features/movies/presentation/providers/movie_repository_provider.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

final FutureProvider<List<Movie>> nowPlayingProvider =
    FutureProvider<List<Movie>>((Ref ref) async {
      final MovieRepository repository = ref.watch(movieRepositoryProvider);
      final Result<List<Movie>> result = await repository.getNowPlaying();
      return switch (result) {
        Success<List<Movie>>(data: final List<Movie> movies) => movies,
        FailureResult<List<Movie>>(failure: final Failure failure) =>
          throw failure,
      };
    });
