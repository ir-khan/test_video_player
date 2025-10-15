import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_video_player/src/utils/enums/media.dart';

part 'media.freezed.dart';

@freezed
abstract class Media with _$Media {
  factory Media({
    final int? id,
    required String title,
    required String path,
    required MediaType mediaType,
    required Duration duration,
  }) = _Media;
}
