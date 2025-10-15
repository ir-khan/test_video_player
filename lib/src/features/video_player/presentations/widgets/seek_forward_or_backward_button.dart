import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'icon_container.dart';

class SeekForwardOrBackwardButton extends StatelessWidget {
  const SeekForwardOrBackwardButton({
    super.key,
    required this.controller,
    required this.isForward,
  });

  final VideoPlayerController controller;
  final bool isForward;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final currentPosition = controller.value.position;
        final seekDuration = Duration(seconds: 5);
        Duration targetPosition = isForward
            ? currentPosition + seekDuration
            : currentPosition - seekDuration;
        controller.seekTo(targetPosition);
      },
      icon: IconContainer(
        icon: isForward ? Icons.forward_5_rounded : Icons.replay_5_rounded,
      ),
    );
  }
}
