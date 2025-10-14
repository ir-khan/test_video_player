import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_video_player/src/utils/enums/media.dart';

part 'media_service.g.dart';

class MediaService {
  final _picker = ImagePicker();

  Future<List<XFile>> pickMedia({MediaType mediaType = MediaType.video}) async {
    /// TODO ( Izn ur Rehman ) : We don't need an extra variable for selected files
    /// we can directly return them
    var files = <XFile>[];
    try {
      switch (mediaType) {
        case MediaType.image:
          files = await _picker.pickMultiImage();
        case MediaType.video:
          files = await _picker.pickMultiVideo();
      }
      return files;
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
MediaService mediaService(Ref _) {
  return MediaService();
}
