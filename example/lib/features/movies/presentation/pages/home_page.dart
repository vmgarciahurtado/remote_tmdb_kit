import 'package:flutter/material.dart';
import 'package:remote_content_explorer/features/movies/presentation/delegates/movie_search_delegate.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/movie_carousel.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/movie_horizontal_list.dart';
import 'package:remote_content_explorer/features/movies/presentation/widgets/section_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explorador de contenido',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => showSearch(
              context: context,
              delegate: MovieSearchDelegate(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 16),
            SectionHeader(
              title: 'Estrenos',
              subtitle: 'Ahora en cartelera',
            ),
            SizedBox(height: 8),
            MovieCarousel(),
            SizedBox(height: 24),
            SectionHeader(
              title: 'Tendencias',
              subtitle: 'Lo más visto esta semana',
            ),
            SizedBox(height: 8),
            MovieHorizontalList(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
