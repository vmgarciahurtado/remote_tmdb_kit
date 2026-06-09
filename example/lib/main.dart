import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/core/config/tmdb_providers.dart';
import 'package:remote_content_explorer/core/constants/env.dart';
import 'package:remote_content_explorer/core/constants/routes.dart';
import 'package:remote_content_explorer/core/theme/theme.dart';
import 'package:riverpod/src/framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    ProviderScope(
      overrides: <Override>[
        tmdbApiKeyProvider.overrideWithValue(Env.apiKey),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Example',
      initialRoute: AppRoutes.initialRoute,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routes: AppRoutes.getRoutes(),
    );
  }
}
