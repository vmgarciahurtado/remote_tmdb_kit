import 'package:flutter/material.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

class MovieOverview extends StatelessWidget {
  const MovieOverview({required this.movie, super.key});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Sinopsis', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            movie.overview.isNotEmpty
                ? movie.overview
                : 'Sin descripción disponible.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
