import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_video_player/src/constants/sizes.dart';
import 'package:test_video_player/src/features/video_player/data/model/media.dart';
import 'package:test_video_player/src/features/video_player/presentations/provider/pick_media_provider.dart';
import 'package:test_video_player/src/features/video_player/presentations/widgets/app_bar_widget.dart';
import 'package:test_video_player/src/features/video_player/presentations/widgets/media_preview_widget.dart';
import 'package:test_video_player/src/features/video_player/presentations/widgets/video_player_widget.dart';
import 'package:test_video_player/src/utils/enums/media.dart';

class SelectVideosPage extends ConsumerStatefulWidget {
  const SelectVideosPage.route(
    BuildContext context,
    GoRouterState state, {
    super.key,
  });

  @override
  ConsumerState<SelectVideosPage> createState() => _SelectVideosPageState();
}

class _SelectVideosPageState extends ConsumerState<SelectVideosPage> {
  final media = <Media>[];
  Media? selectedMedia;

  @override
  void dispose() {
    media.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).orientation == Orientation.portrait
          ? AppBarWidget()
          : null,
      body: Column(
        children: [
          if (selectedMedia == null)
            Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (media.isEmpty)
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: Text(
                      'Please select media from gallery!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    final newMedia = await ref.read(pickMediaProvider.future);
                    if (newMedia.isEmpty) return;
                    media.clear();
                    media.addAll(newMedia);
                    if (!mounted) return;
                    setState(() {});
                  },
                  child: Text('Open Gallery'),
                ),
              ],
            )
          else if (selectedMedia != null)
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.sizeOf(context).height * 0.35
                  : MediaQuery.sizeOf(context).height,
              child: switch (selectedMedia!.mediaType) {
                MediaType.image => Image.file(File(selectedMedia!.path)),
                MediaType.video => VideoPlayerWidget(
                  key: ValueKey(selectedMedia!.title),
                  media: selectedMedia!,
                  onTapSkipPrevious: () {
                    final index = media.indexOf(selectedMedia!);
                    if (index == 0) return;
                    selectedMedia = media[index - 1];
                    if (!mounted) return;
                    setState(() {});
                  },
                  onTapSkipNext: () {
                    final index = media.indexOf(selectedMedia!);
                    if (index == media.length - 1) return;
                    selectedMedia = media[index + 1];
                    if (!mounted) return;
                    setState(() {});
                  },
                  onCompleted: () {
                    final index = media.indexOf(selectedMedia!);
                    if (index == media.length - 1) return;
                    selectedMedia = media[index + 1];
                    if (!mounted) return;
                    setState(() {});
                  },
                ),
              },
            ),

          media.isEmpty
              ? SizedBox.shrink()
              : Expanded(
                  child: ListView.separated(
                    separatorBuilder: (_, _) => SizedBox(height: 15),
                    padding: kPaddingH20V10,
                    itemCount: media.length,
                    itemBuilder: (_, index) {
                      return MediaPreviewWidget(
                        media: media[index],
                        isSelected: media[index] == selectedMedia,
                        onTap: (value) {
                          for (int i = 0; i < media.length; i++) {
                            media[i] = media[i].copyWith(isSelected: false);
                          }
                          selectedMedia = media[index] = media[index].copyWith(
                            isSelected: value,
                          );
                          if (!mounted) return;
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
