import 'package:flutter/material.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE6EBF5),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(.08),
            blurRadius: 34,
            spreadRadius: 1,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
