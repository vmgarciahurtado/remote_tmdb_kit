import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/features/movies/presentation/providers/movie_cast_provider.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/actor_card.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

class CastSection extends ConsumerWidget {
  const CastSection({required this.movieId, super.key});

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(movieCastProvider(movieId))
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (List<Actor> cast) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Reparto',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 165,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: cast.length,
                  itemBuilder: (BuildContext context, int index) =>
                      ActorCard(actor: cast[index]),
                ),
              ),
            ],
          ),
        );
  }
}
