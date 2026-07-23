import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/tip_service.dart';

class MatchDetailScreen extends StatelessWidget {
  final Match match;
  const MatchDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final tip = TipService.calculateTip(match);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E8E3E),
        foregroundColor: Colors.white,
        title: Text('${match.home.name} - ${match.away.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${match.country} - ${match.league}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _TipCard(tip: tip),
          const SizedBox(height: 20),
          const Text('Csapat forma (utolso 5 meccs)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          _FormRow(name: match.home.name, form: match.home.lastForm),
          const SizedBox(height: 6),
          _FormRow(name: match.away.name, form: match.away.lastForm),
          const SizedBox(height: 20),
          const Text('Gol-statisztika',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          _StatTable(match: match),
          const SizedBox(height: 20),
          const Text('Egymas elleni mecsek',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Text(
            '${match.home.name} gyozelmek: ${match.h2h.homeWins} | '
            'Dontetlen: ${match.h2h.draws} | '
            '${match.away.name} gyozelmek: ${match.h2h.awayWins}',
          ),
          Text('Atlagos golszam mecsenkent: ${match.h2h.avgTotalGoals}'),
          const SizedBox(height: 20),
          const Text('Odds-ok',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              _OddsBlock(label: '1', value: match.odds1),
              _OddsBlock(label: 'X', value: match.oddsX),
              _OddsBlock(label: '2', value: match.odds2),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final TipResult tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E8E3E).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF1E8E3E), size: 20),
              const SizedBox(width: 6),
              const Text('AI tipp ajanlas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Javasolt tipp: ${tip.outcomeLabel}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text('Bizalmi szint: ${tip.confidencePercent}%'),
          const SizedBox(height: 8),
          Text(tip.reasoning, style: TextStyle(color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final String name;
  final List<String> form;
  const _FormRow({required this.name, required this.form});

  Color _colorFor(String r) {
    switch (r) {
      case 'W':
        return const Color(0xFF1E8E3E);
      case 'D':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(name)),
        ...form.map(
          (r) => Container(
            margin: const EdgeInsets.only(left: 4),
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _colorFor(r), shape: BoxShape.circle),
            child: Text(r, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ),
      ],
    );
  }
}

class _StatTable extends StatelessWidget {
  final Match match;
  const _StatTable({required this.match});

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String home, String away) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(child: Text(home, textAlign: TextAlign.center)),
              SizedBox(
                  width: 120,
                  child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
              Expanded(child: Text(away, textAlign: TextAlign.center)),
            ],
          ),
        );

    return Column(
      children: [
        row('', match.home.name, match.away.name),
        const Divider(),
        row('Atlagos rugott gol', '${match.home.avgGoalsScored}', '${match.away.avgGoalsScored}'),
        row('Atlagos kapott gol', '${match.home.avgGoalsConceded}', '${match.away.avgGoalsConceded}'),
        row('Tabellahelyezes', '${match.home.leaguePosition}.', '${match.away.leaguePosition}.'),
      ],
    );
  }
}

class _OddsBlock extends StatelessWidget {
  final String label;
  final String value;
  const _OddsBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
