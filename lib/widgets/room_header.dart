import 'package:flutter/material.dart';

import '../models/quiz_room.dart';
import 'app_panel.dart';
import 'status_badge.dart';

class RoomHeader extends StatelessWidget {
  const RoomHeader({super.key, required this.room});

  final QuizRoom room;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppPanel(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 14,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary.withOpacity(.16),
                        scheme.secondary.withOpacity(.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: scheme.primary.withOpacity(.12),
                    ),
                  ),
                  child: Icon(
                    Icons.auto_stories_outlined,
                    color: scheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.title,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Host: ${room.hostName}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusBadge(
                  label: _phaseLabel(room.phase),
                  icon: _phaseIcon(room.phase),
                  color: _phaseColor(room.phase)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary.withOpacity(.12),
                      scheme.primary.withOpacity(.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.primary.withOpacity(.18)),
                ),
                child: SelectableText(
                  room.code,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _phaseLabel(QuizPhase phase) {
    return switch (phase) {
      QuizPhase.lobby => 'Lobby',
      QuizPhase.live => 'Live',
      QuizPhase.leaderboard => 'Leaderboard',
      QuizPhase.review => 'Review',
      QuizPhase.dashboard => 'Dashboard',
    };
  }

  IconData _phaseIcon(QuizPhase phase) {
    return switch (phase) {
      QuizPhase.lobby => Icons.groups_2_outlined,
      QuizPhase.live => Icons.bolt,
      QuizPhase.leaderboard => Icons.leaderboard_outlined,
      QuizPhase.review => Icons.fact_check_outlined,
      QuizPhase.dashboard => Icons.dashboard_outlined,
    };
  }

  Color _phaseColor(QuizPhase phase) {
    return switch (phase) {
      QuizPhase.lobby => const Color(0xFF1D4ED8),
      QuizPhase.live => const Color(0xFF14B8A6),
      QuizPhase.leaderboard => const Color(0xFFF59E0B),
      QuizPhase.review => const Color(0xFF7C3AED),
      QuizPhase.dashboard => const Color(0xFF0F172A),
    };
  }
}
