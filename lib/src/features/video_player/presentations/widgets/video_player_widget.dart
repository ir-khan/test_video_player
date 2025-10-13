import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_video_player/src/extensions/duration.dart';
import 'package:test_video_player/src/features/video_player/data/model/media.dart';
import 'package:test_video_player/src/features/video_player/presentations/widgets/icon_container.dart';
import 'package:test_video_player/src/utils/enums/screen_orientation.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
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
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final VideoPlayerController _controller;
  late final ValueNotifier<Duration> _currentVideoPosition;

  ScreenOrientation _orientation = ScreenOrientation.portraitOnly;
  bool _isVisible = false;
  Timer? _buttonsTimer;

  void _isCompletedListener() {
    if (_controller.value.position == _controller.value.duration) {
      widget.onCompleted();
    }
    _currentVideoPosition.value = _controller.value.position;
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
            onPopInvokedWithResult: (value, result) {
              if (MediaQuery.of(context).orientation == Orientation.landscape) {
                setOrientation(ScreenOrientation.portraitOnly);
              }
            },
            child: GestureDetector(
              onTap: () {
                _isVisible = !_isVisible;
                if (_isVisible) {
                  _buttonsTimer = Timer.periodic(Duration(seconds: 3), (timer) {
                    _isVisible = false;
                    timer.cancel();
                    _buttonsTimer?.cancel();
                    if (!mounted) return;
                    setState(() {});
                  });
                } else {
                  _buttonsTimer?.cancel();
                }
                if (!mounted) return;
                setState(() {});
              },
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
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
                            onPressed: () {
                              Duration currentPosition =
                                  _controller.value.position;
                              Duration targetPosition =
                                  currentPosition - const Duration(seconds: 5);
                              _controller.seekTo(targetPosition);
                            },
                            icon: IconContainer(icon: Icons.replay_5_rounded),
                          ),
                          IconButton(
                            onPressed: () {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                              if (!mounted) return;
                              setState(() {});
                            },
                            icon: IconContainer(
                              icon: _controller.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Duration currentPosition =
                                  _controller.value.position;
                              Duration targetPosition =
                                  currentPosition + const Duration(seconds: 5);
                              _controller.seekTo(targetPosition);
                            },
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
                          width: MediaQuery.sizeOf(context).width,
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
                                    onPressed: () {
                                      _orientation =
                                          _orientation ==
                                              ScreenOrientation.portraitOnly
                                          ? ScreenOrientation.landscapeOnly
                                          : ScreenOrientation.portraitOnly;
                                      setOrientation(_orientation);
                                    },
                                    icon: IconContainer(
                                      icon:
                                          MediaQuery.of(context).orientation ==
                                              Orientation.portrait
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
