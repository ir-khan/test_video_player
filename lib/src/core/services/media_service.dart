import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_video_player/src/utils/enums/media.dart';

part 'media_service.g.dart';

class MediaService {
  final _picker = ImagePicker();

  Future<List<XFile>> pickMedia({MediaType mediaType = MediaType.video}) async {
    /// ✅ TODO ( Izn ur Rehman ) : We don't need an extra variable for selected files
    /// we can directly return them
    try {
      switch (mediaType) {
        case MediaType.image:
          return await _picker.pickMultiImage();
        case MediaType.video:
          return await _picker.pickMultiVideo();
      }
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
MediaService mediaService(Ref _) {
  return MediaService();
}
