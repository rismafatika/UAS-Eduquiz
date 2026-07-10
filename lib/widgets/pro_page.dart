import 'package:flutter/material.dart';

class ProPage extends StatelessWidget {
  const ProPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.maxWidth = 1000,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF3F6FF),
            Color(0xFFF9FBFF),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1D4ED8),
                          Color(0xFF5B5FEF),
                          Color(0xFF8B5CF6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B5FEF).withOpacity(.22),
                          blurRadius: 32,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -18,
                          top: -24,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(.12),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.14),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
