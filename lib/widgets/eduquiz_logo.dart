import 'package:flutter/material.dart';

class EduQuizLogo extends StatelessWidget {
  const EduQuizLogo({
    super.key,
    this.size = 64,
    this.borderRadius = 18,
    this.fit = BoxFit.cover,
  });

  final double size;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/images/eduquiz_logo.png',
        width: size,
        height: size,
        fit: fit,
      ),
    );
  }
}
