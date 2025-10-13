import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_video_player/src/core/services/media_service.dart';
import 'package:test_video_player/src/features/video_player/data/model/media.dart';
import 'package:test_video_player/src/features/video_player/presentations/provider/toggle_media_type.dart';

part 'pick_media_provider.g.dart';

@riverpod
Future<List<Media>> pickMedia(Ref ref) async {
  final mediaType = ref.watch(toggleMediaTypeProvider);
  final files = await ref
      .watch(mediaServiceProvider)
      .pickMedia(mediaType: mediaType);

  return files
      .map(
        (file) =>
            Media(title: file.name, path: file.path, mediaType: mediaType),
      )
      .toList();
}
