import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/features/movies/presentation/providers/popular_movies_provider.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/content_shell.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/error_retry.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/popular_card.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

class MovieHorizontalList extends ConsumerStatefulWidget {
  const MovieHorizontalList({super.key});

  @override
  ConsumerState<MovieHorizontalList> createState() =>
      _MovieHorizontalListState();
}

class _MovieHorizontalListState extends ConsumerState<MovieHorizontalList> {
  late final PageController _controller;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.3);
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_controller.hasClients) return;
      final List<Movie> movies =
          ref.read(popularMoviesProvider).value ?? <Movie>[];
      if (movies.isEmpty) return;
      final int next = ((_controller.page?.round() ?? 0) + 1) % movies.length;
      unawaited(
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Movie>> state = ref.watch(popularMoviesProvider);
    final List<Movie> movies = state.value ?? <Movie>[];

    if (state.isLoading && movies.isEmpty) {
      return const ContentShell(
        heightFactor: 0.20,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.hasError && movies.isEmpty) {
      final Object? error = state.error;
      return ContentShell(
        heightFactor: 0.20,
        child: ErrorRetry(
          compact: true,
          message: error is Failure ? error.userMessage : null,
          onRetry: () => ref.invalidate(popularMoviesProvider),
        ),
      );
    }

    return ContentShell(
      heightFactor: 0.20,
      child: PageView.builder(
        padEnds: false,
        controller: _controller,
        itemCount: movies.length,
        itemBuilder: (BuildContext context, int index) =>
            PopularCard(movie: movies[index]),
      ),
    );
  }
}
