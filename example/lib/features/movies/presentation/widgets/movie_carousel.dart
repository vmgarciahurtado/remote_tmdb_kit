import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/features/movies/presentation/providers/now_playing_provider.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/content_shell.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/error_retry.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/movie_card.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

class MovieCarousel extends ConsumerStatefulWidget {
  const MovieCarousel({super.key});

  @override
  ConsumerState<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends ConsumerState<MovieCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Movie>> state = ref.watch(nowPlayingProvider);

    return state.when(
      loading: () => const ContentShell(
        heightFactor: 0.56,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace __) => ContentShell(
        heightFactor: 0.56,
        child: ErrorRetry(
          message: error is Failure ? error.userMessage : null,
          onRetry: () => ref.invalidate(nowPlayingProvider),
        ),
      ),
      data: (List<Movie> movies) => ContentShell(
        heightFactor: 0.56,
        child: PageView.builder(
          controller: _controller,
          itemCount: movies.length,
          itemBuilder: (BuildContext context, int index) => MovieCard(
            movie: movies[index],
            controller: _controller,
            index: index,
          ),
        ),
      ),
    );
  }
}
