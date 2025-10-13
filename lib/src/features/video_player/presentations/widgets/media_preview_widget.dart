import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_video_player/src/constants/sizes.dart';
import 'package:test_video_player/src/features/video_player/data/model/media.dart';
import 'package:test_video_player/src/utils/enums/media.dart';

class MediaPreviewWidget extends StatelessWidget {
  const MediaPreviewWidget({
    super.key,
    required this.media,
    required this.onTap, required this.isSelected,
  });

  final Media media;
  final bool isSelected;
  final void Function(bool) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(!media.isSelected),
      child: Container(
        padding: kPadding5,
        decoration: BoxDecoration(borderRadius: kRadius20),
        child: Row(
          spacing: 10,
          children: [
            Container(
              padding: kPadding5,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: kRadius10,
                border: isSelected ? Border.all(color: Colors.red) : null,
              ),
              child: ClipRRect(
                borderRadius: kRadius5,
                child: switch (media.mediaType) {
                  MediaType.image => Image.file(
                    File(media.path),
                    width: 100,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  MediaType.video => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 100, height: 60),
                      Positioned(
                        child: Container(
                          padding: kPadding5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF303030),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 30,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                },
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  Text(
                    media.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    media.mediaType.toString(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
