import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/participant.dart';
import '../services/room_service.dart';

class StatistikPage extends StatelessWidget {
  final AppUser user;

  const StatistikPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final rooms = RoomService.instance.getAllRooms();
    int totalKuis = 0;
    int totalBenar = 0;
    int totalSoal = 0;
    int totalSkor = 0;
    int skorTertinggi = 0;

    for (var room in rooms) {
      final participant = room.participants.firstWhere(
        (p) => p.name == user.name,
        orElse: () => Participant(name: user.name, score: 0),
      );
      if (participant.score > 0 || participant.answers.isNotEmpty) {
        totalKuis++;
        totalSkor += participant.score;
        if (participant.score > skorTertinggi)
          skorTertinggi = participant.score;
        for (var i = 0; i < room.questions.length; i++) {
          if (participant.answers.containsKey(i) &&
              participant.answers[i] == room.questions[i].correctIndex) {
            totalBenar++;
          }
          totalSoal++;
        }
      }
    }

    final avgSkor = totalKuis > 0 ? totalSkor / totalKuis : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatCard('Total Kuis', '$totalKuis'),
            _StatCard('Skor Tertinggi', '$skorTertinggi'),
            _StatCard('Rata-rata Skor', avgSkor.toStringAsFixed(1)),
            _StatCard('Benar / Total', '$totalBenar / $totalSoal'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing:
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
