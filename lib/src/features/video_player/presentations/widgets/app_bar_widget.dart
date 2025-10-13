import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_video_player/src/features/video_player/presentations/provider/toggle_media_type.dart';
import 'package:test_video_player/src/utils/enums/media.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Select Media'),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final mediaType = ref.watch(toggleMediaTypeProvider);
            return TextButton(
              onPressed: () {
                ref.read(toggleMediaTypeProvider.notifier).setType(
                  switch (mediaType) {
                    MediaType.image => MediaType.video,
                    MediaType.video => MediaType.image,
                  },
                );
              },
              child: Text(switch (mediaType) {
                MediaType.image => 'Image',
                MediaType.video => 'Video',
              }),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
