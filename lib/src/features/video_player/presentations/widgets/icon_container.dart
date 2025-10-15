import 'package:flutter/material.dart';
import 'package:test_video_player/src/constants/sizes.dart';

class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    required this.icon,
    this.margin,
    required this.onPressed,
  });

  final IconData icon;
  final EdgeInsetsGeometry? margin;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: kPadding5,
        margin: margin,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF303030),
        ),
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }
}
