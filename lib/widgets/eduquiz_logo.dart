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
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: const Color(0xFF7DD3FC), width: 1.2),
            ),
            child: Icon(
              Icons.quiz_rounded,
              size: size * 0.56,
              color: const Color(0xFF0284C7),
            ),
          );
        },
      ),
    );
  }
}
