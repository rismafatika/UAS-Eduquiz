import 'package:flutter/material.dart';

import '../models/quiz_room.dart';
import 'app_panel.dart';
import 'status_badge.dart';

class RoomHeader extends StatelessWidget {
  const RoomHeader({super.key, required this.room});

  final QuizRoom room;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 14,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                ),
                child: Icon(Icons.auto_stories_outlined, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text('Host: ${room.hostName}', style: const TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusBadge(label: _phaseLabel(room.phase), icon: _phaseIcon(room.phase), color: _phaseColor(room.phase)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: SelectableText(
                  room.code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
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
