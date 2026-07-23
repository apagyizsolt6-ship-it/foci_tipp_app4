import 'package:flutter/material.dart';
import '../data/mock_matches.dart';
import '../models/match.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Map<String, List<Match>> _groupByLeague(List<Match> matches) {
    final map = <String, List<Match>>{};
    for (final m in matches) {
      map.putIfAbsent('${m.country} - ${m.league}', () => []).add(m);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByLeague(mockMatches);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8E3E),
        foregroundColor: Colors.white,
        title: const Text('Foci Tipp - Elemzo'),
        centerTitle: false,
      ),
      body: ListView(
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFFEFF7F0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E8E3E),
                  ),
                ),
              ),
              ...entry.value.map(
                (match) => MatchCard(
                  match: match,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MatchDetailScreen(match: match),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
