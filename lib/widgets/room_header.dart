import 'package:flutter/material.dart';

import '../models/quiz_room.dart';
import 'app_panel.dart';

class RoomHeader extends StatelessWidget {
  const RoomHeader({super.key, required this.room});

  final QuizRoom room;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(room.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('Host: ${room.hostName}'),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(room.code, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
