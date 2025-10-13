import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_video_player/src/utils/enums/media.dart';

part 'toggle_media_type.g.dart';

@riverpod
class ToggleMediaType extends _$ToggleMediaType {
  @override
  MediaType build() => MediaType.video;

  void setType(MediaType newType) {
    state = newType;
  }
}
