import 'package:flutter/material.dart';

import '../models/quiz_room.dart';
import 'app_panel.dart';

class RoomHeader extends StatelessWidget {
  const RoomHeader({super.key, required this.room});

  final QuizRoom room;

  @override
  Widget build(BuildContext context) {
    final phaseLabel = switch (room.phase) {
      QuizPhase.lobby => 'Lobby',
      QuizPhase.live => 'Live',
      QuizPhase.leaderboard => 'Leaderboard',
      QuizPhase.review => 'Review',
      QuizPhase.dashboard => 'Dashboard',
    };

    return AppPanel(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(room.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeaderChip(
                      icon: Icons.person_outline,
                      label: 'Host: ${room.hostName}'),
                  _HeaderChip(
                      icon: Icons.groups_2_outlined,
                      label: '${room.participants.length} peserta'),
                  _HeaderChip(icon: Icons.bolt_outlined, label: phaseLabel),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.28)),
            ),
            child: Text(
              room.code,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF334155))),
        ],
      ),
    );
  }
}
