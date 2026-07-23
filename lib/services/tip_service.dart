import 'dart:math';
import '../models/match.dart';

enum TipOutcome { home, draw, away }

class TipResult {
  final TipOutcome outcome;
  final double confidencePercent; // 0-100
  final String reasoning; // rovid, "AI-szeru" magyarazat
  final double expectedHomeGoals;
  final double expectedAwayGoals;

  const TipResult({
    required this.outcome,
    required this.confidencePercent,
    required this.reasoning,
    required this.expectedHomeGoals,
    required this.expectedAwayGoals,
  });

  String get outcomeLabel {
    switch (outcome) {
      case TipOutcome.home:
        return '1 (hazai gyozelem)';
      case TipOutcome.draw:
        return 'X (dontetlen)';
      case TipOutcome.away:
        return '2 (vendeg gyozelem)';
    }
  }
}

/// Statisztika-alapu tippszamitas + "AI" stilusu, ember-olvashato indoklas.
///
/// FONTOS: ez jelenleg egy determinisztikus, szabaly-alapu heurisztika
/// (forma, gol-atlagok, tabellahelyezes, egymas elleni mecssek).
/// Ha kesobb valodi LLM-hivast szeretnel a "reasoning" szoveg
/// generalasahoz (pl. az Anthropic API-n keresztul), ezt a szolgaltatast
/// bovitheted egy HTTP hivassal - a strukturat ugy alakitottuk ki, hogy
/// ez konnyen beepitheto legyen kesobb, API kulcs birtokaban.
class TipService {
  static TipResult calculateTip(Match match) {
    final home = match.home;
    final away = match.away;

    // 1) Forma-pontszam sullyozott atlaga
    final formDiff = home.formScore - away.formScore;

    // 2) Gol-kulonbseg alapu varhato golok (nagyon egyszerusitett Poisson-kozeliles)
    final expectedHomeGoals =
        (home.avgGoalsScored + away.avgGoalsConceded) / 2 * 1.1; // hazai palya elony
    final expectedAwayGoals =
        (away.avgGoalsScored + home.avgGoalsConceded) / 2;

    // 3) Tabellahelyezes-kulonbseg (kisebb szam = jobb helyezes)
    final positionDiff = away.leaguePosition - home.leaguePosition;

    // 4) Egymas elleni mérlegek
    final h2hTotal = match.h2h.homeWins + match.h2h.draws + match.h2h.awayWins;
    final h2hHomeRatio = h2hTotal > 0 ? match.h2h.homeWins / h2hTotal : 0.34;
    final h2hAwayRatio = h2hTotal > 0 ? match.h2h.awayWins / h2hTotal : 0.34;

    // Osszesitett "hazai elony" pontszam, tobb tenyezobol
    final homeAdvantageScore = (formDiff * 0.4) +
        ((expectedHomeGoals - expectedAwayGoals) * 3.0) +
        (positionDiff * 0.3) +
        ((h2hHomeRatio - h2hAwayRatio) * 5.0);

    TipOutcome outcome;
    if (homeAdvantageScore > 1.5) {
      outcome = TipOutcome.home;
    } else if (homeAdvantageScore < -1.5) {
      outcome = TipOutcome.away;
    } else {
      outcome = TipOutcome.draw;
    }

    // Bizalmi szint: minel nagyobb az abszolut ertek, annal magabiztosabb a tipp
    final rawConfidence = 50 + min(homeAdvantageScore.abs() * 6, 40);
    final confidence = double.parse(rawConfidence.toStringAsFixed(1));

    final reasoning = _buildReasoning(
      match: match,
      outcome: outcome,
      formDiff: formDiff,
      expectedHomeGoals: expectedHomeGoals,
      expectedAwayGoals: expectedAwayGoals,
    );

    return TipResult(
      outcome: outcome,
      confidencePercent: confidence,
      reasoning: reasoning,
      expectedHomeGoals: double.parse(expectedHomeGoals.toStringAsFixed(2)),
      expectedAwayGoals: double.parse(expectedAwayGoals.toStringAsFixed(2)),
    );
  }

  static String _buildReasoning({
    required Match match,
    required TipOutcome outcome,
    required double formDiff,
    required double expectedHomeGoals,
    required double expectedAwayGoals,
  }) {
    final home = match.home.name;
    final away = match.away.name;
    final buffer = StringBuffer();

    if (formDiff.abs() > 3) {
      final better = formDiff > 0 ? home : away;
      buffer.write('$better jelentosen jobb formaban van az utobbi meccsek alapjan. ');
    } else {
      buffer.write('A ket csapat formaja kiegyensulyozott az utobbi meccsek alapjan. ');
    }

    if ((expectedHomeGoals - expectedAwayGoals).abs() > 0.7) {
      buffer.write(
        expectedHomeGoals > expectedAwayGoals
            ? '$home tamadasban es vedekezesben is elonyben van a golatlagok szerint. '
            : '$away golatlagai kedvezobb kepet mutatnak, mint a hazai csapate. ',
      );
    }

    if (match.h2h.homeWins != match.h2h.awayWins) {
      final leader = match.h2h.homeWins > match.h2h.awayWins ? home : away;
      buffer.write('Az eddigi egymas elleni mecsekben tobbszor nyert a(z) $leader. ');
    }

    buffer.write(
      'Ezek alapjan a becsult eredmeny kb. ${expectedHomeGoals.toStringAsFixed(1)}'
      '-${expectedAwayGoals.toStringAsFixed(1)} korul alakulhat.',
    );

    return buffer.toString();
  }
}
