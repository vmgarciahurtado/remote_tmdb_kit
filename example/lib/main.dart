import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_content_explorer/core/constants/routes.dart';
import 'package:remote_content_explorer/core/theme/theme.dart';

void main() async {
  await dotenv.load();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remote content explorer',
      initialRoute: AppRoutes.initialRoute,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routes: AppRoutes.getRoutes(),
    );
  }
}
