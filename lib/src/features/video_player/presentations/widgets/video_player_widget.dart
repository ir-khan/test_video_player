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
    if (_controller.value.position == _controller.value.duration) {
      widget.onCompleted();
    }
    ref
        .read(playPauseProviderProvider.notifier)
        .setValue(_controller.value.isPlaying);
    _currentVideoPosition.value = _controller.value.position;
  }

  void _seekForwardOrBackward({required bool isForward}) {
    final currentPosition = _controller.value.position;
    final seekDuration = Duration(seconds: 5);
    Duration targetPosition = isForward
        ? currentPosition + seekDuration
        : currentPosition - seekDuration;
    _controller.seekTo(targetPosition);
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.media.path))
      ..initialize().then((_) {
        setState(() {});
        _currentVideoPosition = ValueNotifier(_controller.value.position);
        _controller.addListener(_isCompletedListener);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.removeListener(_isCompletedListener);
    _controller.dispose();
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
                _isVisible = !_isVisible;
                if (_isVisible) {
                  /// ✅ TODO ( Izn Ur Rehman ) : Why are we using periodic Timer since it is a one time task
                  /// and why are we cancelling timer twice?
                  /// ✅ TODO ( Izn ur Rehman ) : The controls are not getting visible when
                  /// I tap outside of the video Aspect Ratio!
                  _buttonsTimer = Timer(Duration(seconds: 3), () {
                    _isVisible = false;
                    if (!mounted) return;
                    setState(() {});
                  });
                } else {
                  _buttonsTimer?.cancel();
                }
                if (!mounted) return;
                setState(() {});
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
                          IconButton(
                            /// ✅ TODO ( Izn ur Rehman ) : Create a reusable single function and use that on forward and reversed seek
                            onPressed: () =>
                                _seekForwardOrBackward(isForward: false),
                            icon: IconContainer(icon: Icons.replay_5_rounded),
                          ),
                          IconButton(
                            onPressed: () async {
                              final value = ref.read(playPauseProviderProvider);
                              if (value) {
                                ref
                                    .read(playPauseProviderProvider.notifier)
                                    .setValue(false);
                                await _controller.pause();
                              } else {
                                ref
                                    .read(playPauseProviderProvider.notifier)
                                    .setValue(true);
                                await _controller.play();
                              }
                            },
                            icon: Consumer(
                              builder: (context, ref, child) {
                                final playPauseValue = ref.watch(
                                  playPauseProviderProvider,
                                );
                                return IconContainer(
                                  icon: playPauseValue
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                );
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _seekForwardOrBackward(isForward: true),
                            icon: IconContainer(icon: Icons.forward_5_rounded),
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
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
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
                                      orientation == Orientation.portrait
                                          ? await SystemChrome.setPreferredOrientations(
                                              [
                                                DeviceOrientation.landscapeLeft,
                                                DeviceOrientation
                                                    .landscapeRight,
                                              ],
                                            )
                                          : await SystemChrome.setPreferredOrientations(
                                              [DeviceOrientation.portraitUp],
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
