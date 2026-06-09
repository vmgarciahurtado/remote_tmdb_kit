import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/cast_section.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/detail_app_bar.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/movie_overview.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/poster_and_title.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

class MovieDetailPage extends ConsumerWidget {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Movie movie = ModalRoute.of(context)!.settings.arguments as Movie;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          DetailAppBar(movie: movie),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              PosterAndTitle(movie: movie),
              MovieOverview(movie: movie),
              CastSection(movieId: movie.id),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }
}
