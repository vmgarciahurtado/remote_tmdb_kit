import 'package:flutter/material.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/network_image_with_fallback.dart';
import 'package:remote_tmdb_kit/remote_tmdb_kit.dart';

class ActorCard extends StatelessWidget {
  const ActorCard({required this.actor, super.key});

  final Actor actor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: <Widget>[
          ClipOval(
            child: SizedBox(
              width: 90,
              height: 90,
              child: NetworkImageWithFallback(
                url: actor.profilePath,
                showLoader: true,
                loaderStrokeWidth: 2,
                fallback: const ColoredBox(
                  color: Colors.black12,
                  child: Icon(Icons.person, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 90,
            child: Text(
              actor.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (actor.character.isNotEmpty)
            SizedBox(
              width: 90,
              child: Text(
                actor.character,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
