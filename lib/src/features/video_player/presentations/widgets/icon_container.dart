import 'package:flutter/material.dart';
import 'package:test_video_player/src/constants/sizes.dart';

class IconContainer extends StatelessWidget {
  const IconContainer({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPadding5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF303030),
      ),
      child: Icon(icon, size: 30, color: Colors.white70),
    );
  }
}
