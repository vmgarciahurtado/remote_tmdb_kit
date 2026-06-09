import 'package:flutter/material.dart';
import 'package:remote_content_explorer/core/constants/routes.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/network_image_with_fallback.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

class PopularCard extends StatelessWidget {
  const PopularCard({required this.movie, super.key});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.movieDetail,
        arguments: movie,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Hero(
          tag: 'movie-popular-${movie.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: NetworkImageWithFallback(
              url: movie.posterPath,
              showLoader: true,
              loaderStrokeWidth: 2,
              fallback: const ColoredBox(
                color: Colors.black12,
                child: Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
