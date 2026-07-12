import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/participant.dart';
import '../models/quiz_room.dart';
import '../services/room_service.dart';

class RiwayatPage extends StatelessWidget {
  final AppUser user;

  const RiwayatPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final rooms = RoomService.instance.getAllRooms();
    final histories = <_HistoryData>[];

    for (var room in rooms) {
      final participant = room.participants.firstWhere(
        (p) => p.name == user.name,
        orElse: () => Participant(name: user.name, score: 0),
      );
      if (participant.score > 0 || participant.answers.isNotEmpty) {
        int benar = 0;
        for (var i = 0; i < room.questions.length; i++) {
          if (participant.answers.containsKey(i) &&
              participant.answers[i] == room.questions[i].correctIndex) {
            benar++;
          }
        }
        histories.add(_HistoryData(
          title: room.title,
          score: participant.score,
          benar: benar,
          total: room.questions.length,
          rank: room.participants.indexOf(participant) + 1,
          date: room.createdAt,
        ));
      }
    }

    // Urutkan dari yang terbaru
    histories.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kuis')),
      body: histories.isEmpty
          ? const Center(child: Text('Belum ada riwayat'))
          : ListView.builder(
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final h = histories[index];
                return ListTile(
                  title: Text(h.title),
                  subtitle: Text(
                      'Skor: ${h.score}  •  Benar: ${h.benar}/${h.total}  •  Rank: #${h.rank}'),
                  trailing:
                      Text('${h.date.day}/${h.date.month}/${h.date.year}'),
                );
              },
            ),
    );
  }
}

class _HistoryData {
  final String title;
  final int score;
  final int benar;
  final int total;
  final int rank;
  final DateTime date;

  _HistoryData({
    required this.title,
    required this.score,
    required this.benar,
    required this.total,
    required this.rank,
    required this.date,
  });
}
