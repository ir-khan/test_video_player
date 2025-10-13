import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_video_player/src/router/router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  MyApp.initialize({super.key}) {
    runApp(ProviderScope(child: MyApp()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Test Video Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      routerConfig: ref.watch(routerConfigProvider),
    );
  }
}
