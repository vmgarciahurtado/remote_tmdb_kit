import 'package:flutter/material.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/network_image_with_fallback.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

class PosterAndTitle extends StatelessWidget {
  const PosterAndTitle({required this.movie, super.key});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: 'movie-poster-${movie.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetworkImageWithFallback(
                url: movie.posterPath,
                width: 110,
                fallback: const SizedBox(
                  width: 110,
                  child: ColoredBox(
                    color: Colors.black12,
                    child: Icon(Icons.movie, size: 48),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  movie.originalTitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
