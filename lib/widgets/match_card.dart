import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/tip_service.dart';

/// Egy sor a meccslistaban - hasonlit az eredmenyek.com tipusu
/// elo-eredmeny oldalak lista-nezetere: ido, csapatok, oddsok, mini tipp-jelzo.
class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tip = TipService.calculateTip(match);
    final timeLabel =
        '${match.kickoff.hour.toString().padLeft(2, '0')}:${match.kickoff.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                timeLabel,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.home.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(match.away.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Row(
              children: [
                _OddsChip(label: '1', value: match.odds1),
                const SizedBox(width: 4),
                _OddsChip(label: 'X', value: match.oddsX),
                const SizedBox(width: 4),
                _OddsChip(label: '2', value: match.odds2),
              ],
            ),
            const SizedBox(width: 8),
            _TipBadge(tip: tip),
          ],
        ),
      ),
    );
  }
}

class _OddsChip extends StatelessWidget {
  final String label;
  final String value;
  const _OddsChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TipBadge extends StatelessWidget {
  final TipResult tip;
  const _TipBadge({required this.tip});

  @override
  Widget build(BuildContext context) {
    final label = switch (tip.outcome) {
      TipOutcome.home => '1',
      TipOutcome.draw => 'X',
      TipOutcome.away => '2',
    };
    return Container(
      margin: const EdgeInsets.only(left: 6),
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1E8E3E),
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
