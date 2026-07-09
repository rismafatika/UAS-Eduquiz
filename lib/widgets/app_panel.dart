import 'package:flutter/material.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
<<<<<<< HEAD
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xffECECF3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(.08),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 12),
=======
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
>>>>>>> origin/rista-ui
          ),
        ],
      ),
      child: child,
    );
  }
}