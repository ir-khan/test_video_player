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
import 'package:test_video_player/src/mixin/media_query_mixin.dart';
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

class _SelectVideosPageState extends ConsumerState<SelectVideosPage>
    with MediaQueryMixin {
  final media = <Media>[];
  Media? selectedMedia;

  @override
  void dispose() {
    media.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ TODO ( Izn ur Rehman ) : Create a single instance of MediaQuery and Use that instance everywhere
    /// for size use sizeOf and for orientation use orientationOfa
    return Scaffold(
      appBar: orientation == Orientation.portrait ? AppBarWidget() : null,
      body: Column(
        children: [
          if (selectedMedia != null)
            SizedBox(
              width: size.width,
              height: orientation == Orientation.portrait
                  ? size.height * 0.35
                  : size.height,
              child: switch (selectedMedia!.mediaType) {
                MediaType.image => Image.file(File(selectedMedia!.path)),
                MediaType.video => VideoPlayerWidget(
                  key: ValueKey(selectedMedia!.id),
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
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: kPadding5,
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (media.isEmpty)
                          SizedBox(
                            width: size.width,
                            child: Text(
                              'Please select media from gallery!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () async {
                            final newMedia = await ref.read(
                              pickMediaProvider.future,
                            );
                            if (newMedia.isEmpty) return;
                            for (final m in newMedia) {
                              media.add(m.copyWith(id: media.length));
                            }
                            if (!mounted) return;
                            setState(() {});
                          },
                          child: Text('Open Gallery'),
                        ),
                      ],
                    ),
                  ),
                ),

                if (media.isNotEmpty)
                  SliverPadding(
                    padding: kPaddingH20V10,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((_, index) {
                        return MediaPreviewWidget(
                          media: media[index],
                          isSelected: media[index] == selectedMedia,
                          onTap: () {
                            /// ✅ TODO ( Izn ur Rehman ) : The Below functionality is not correct
                            /// Please Fix this
                            selectedMedia = media[index];
                            if (!mounted) return;
                            setState(() {});
                          },
                        );
                      }, childCount: media.length),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ TODO ( Izn ur Rehman ) : Total duration is not displaying
/// ✅ TODO ( Izn ur Rehman ) : I am unable to select more videos when the video is playing

/// ✅ New TODO ( Izn ur Rehman ) : The Time is not displaying correctly when we select videos from Gallery and Also when we play the video the Time is not displaying correctly after the changes you make
/// ✅ New TODO ( Izn ur Rehman ) : If we select same video twice and play the first video and then click on Second video it continues playing the first video and does not switch to new tapped video
/// ✅ New TODO ( Izn ur Rehman ) : I am facing issue while seeking video from progressbar
