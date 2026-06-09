import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:remote_content_explorer/features/movies/presentation/providers/movie_repository_provider.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

final FutureProviderFamily<List<Actor>, int> movieCastProvider =
    FutureProvider.family<List<Actor>, int>((Ref ref, int movieId) async {
      final MovieRepository repository = ref.watch(movieRepositoryProvider);
      final Result<List<Actor>> result = await repository.getMovieCast(movieId);
      return switch (result) {
        Success<List<Actor>>(data: final List<Actor> cast) => cast,
        FailureResult<List<Actor>>(failure: final Failure failure) =>
          throw failure,
      };
    });
