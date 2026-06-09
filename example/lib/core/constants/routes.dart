import 'package:flutter/material.dart';
import 'package:remote_content_explorer/features/movies/presentation/pages/home_page.dart';
import 'package:remote_content_explorer/features/movies/presentation/pages/movie_detail_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String initialRoute = '/';
  static const String movieDetail = '/movie-detail';

  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      initialRoute: (BuildContext _) => const HomePage(),
      movieDetail: (BuildContext _) => const MovieDetailPage(),
    };
  }
}
