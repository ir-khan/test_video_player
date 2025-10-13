import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_video_player/src/features/video_player/presentations/select_videos_page.dart';
import 'package:test_video_player/src/router/routes.dart';

part 'router.g.dart';

@riverpod
GoRouter routerConfig(Ref _) {
  return GoRouter(
    initialLocation: AppRoutes.initialLocation.path,
    routes: [
      GoRoute(
        name: AppRoutes.selectVideos.name,
        path: AppRoutes.selectVideos.path,
        builder: SelectVideosPage.route,
      ),
    ],
  );
}
