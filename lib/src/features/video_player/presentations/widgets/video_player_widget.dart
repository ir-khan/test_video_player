import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_video_player/src/extensions/duration.dart';
import 'package:test_video_player/src/features/video_player/data/model/media.dart';
import 'package:test_video_player/src/features/video_player/presentations/provider/play_pause_provider.dart';
import 'package:test_video_player/src/features/video_player/presentations/widgets/icon_container.dart';
import 'package:test_video_player/src/mixin/media_query_mixin.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.media,
    required this.onTapSkipPrevious,
    required this.onTapSkipNext,
    required this.onCompleted,
  });

  final Media media;
  final VoidCallback onTapSkipPrevious;
  final VoidCallback onTapSkipNext;
  final VoidCallback onCompleted;

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget>
    with MediaQueryMixin {
  late final VideoPlayerController _controller;
  late final ValueNotifier<Duration> _currentVideoPosition;

  /// ✅ Extract the Current Orientation from MediaQuery
  bool _isVisible = false;
  Timer? _buttonsTimer;

  void _isCompletedListener() {
    final value = _controller.value;
    _currentVideoPosition.value = value.position;

    if (value.position >= value.duration) widget.onCompleted();
    ref.read(playPauseProvider.notifier).setValue(value.isPlaying);
  }

  void _seekForwardOrBackword({required bool isForward}) {
    final current = _controller.value.position;
    final seekOffset = const Duration(seconds: 5);
    final target = isForward ? current + seekOffset : current - seekOffset;
    _controller.seekTo(target);
  }

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.file(File(widget.media.path));
    await _controller.initialize();

    if (!mounted) return;

    _currentVideoPosition = ValueNotifier(_controller.value.position);
    _controller
      ..addListener(_isCompletedListener)
      ..play();

    ref.read(playPauseProvider.notifier).setValue(true);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_isCompletedListener);
    _controller.dispose();
    _currentVideoPosition.dispose();
    _buttonsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? PopScope(
            canPop: false,
            onPopInvokedWithResult: (value, result) async {
              /// ✅ TODO ( Izn ur Rehman ) : Create a single Instance of MediaQuery
              if (orientation == Orientation.landscape) {
                /// ✅ TODO ( Izn ur Rehman ) : We don't need this `setOrientation` function since it is a one line call
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
            },
            child: GestureDetector(
              onTap: () {
                /// ✅ New TODO ( Izn ur Rehman ) : More changes required here
                /// ✅ TODO ( Izn Ur Rehman ) : Why are we using periodic Timer since it is a one time task
                /// and why are we cancelling timer twice?
                /// ✅ TODO ( Izn ur Rehman ) : The controls are not getting visible when
                /// I tap outside of the video Aspect Ratio!
                ///
                _isVisible = !_isVisible;
                setState(() {});

                _buttonsTimer?.cancel();
                if (_isVisible) {
                  _buttonsTimer = Timer(const Duration(seconds: 3), () {
                    if (mounted) setState(() => _isVisible = false);
                  });
                }
              },
              child: Container(
                color: Colors.grey.shade600,
                width: size.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    Visibility(
                      visible: _isVisible,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          /// ✅ New TODO ( Izn ur Rehman ) : More Optimization Required
                          /// ✅ TODO ( Izn ur Rehman ) : Create a reusable single function and use that on forward and reversed seek
                          IconButton(
                            onPressed: () =>
                                _seekForwardOrBackword(isForward: false),
                            icon: const IconContainer(
                              icon: Icons.replay_5_rounded,
                            ),
                          ),
                          Consumer(
                            builder: (_, ref, _) {
                              final playPauseValue = ref.watch(
                                playPauseProvider,
                              );
                              return IconButton(
                                onPressed: () async {
                                  /// ✅ New TODO ( Izn ur Rehman ) : More Optimization Required in this function code
                                  final isPlaying = ref.read(playPauseProvider);
                                  isPlaying
                                      ? await _controller.pause()
                                      : await _controller.play();
                                  ref
                                      .read(playPauseProvider.notifier)
                                      .setValue(!isPlaying);
                                },
                                icon: IconContainer(
                                  icon: playPauseValue
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () =>
                                _seekForwardOrBackword(isForward: false),
                            icon: const IconContainer(
                              icon: Icons.forward_5_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _isVisible,
                      child: Positioned(
                        bottom: 0,
                        child: SizedBox(
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 2),
                                child: ValueListenableBuilder(
                                  valueListenable: _currentVideoPosition,
                                  builder: (context, value, child) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF303030),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${value.format()} / ${_controller.value.duration.format()}',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 10,
                                child: VideoProgressIndicator(
                                  _controller,
                                  allowScrubbing: true,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: widget.onTapSkipPrevious,
                                        icon: IconContainer(
                                          icon: Icons.skip_previous_rounded,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: widget.onTapSkipNext,
                                        icon: IconContainer(
                                          icon: Icons.skip_next_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      /// ✅ TODO ( Izn ur Rehman ) : Extract orientation from MediaQuery and remove setOrientation function and call functionality directly
                                      /// ✅ New TODO ( Izn ur Rehman ) : More Optimization Required
                                      await SystemChrome.setPreferredOrientations(
                                        [
                                          orientation == Orientation.portrait
                                              ? DeviceOrientation.landscapeLeft
                                              : DeviceOrientation.portraitUp,
                                        ],
                                      );
                                    },
                                    icon: IconContainer(
                                      icon: orientation == Orientation.portrait
                                          ? Icons.fullscreen_rounded
                                          : Icons.fullscreen_exit_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : SizedBox();
  }
}

/// ✅ TODO ( Izn Ur Rehman ) : When all the videos played and you restart the last video again
/// the Icon did not change from Pause to play
