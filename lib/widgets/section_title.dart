import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primary.withOpacity(.14),
                scheme.secondary.withOpacity(.10),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: scheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
