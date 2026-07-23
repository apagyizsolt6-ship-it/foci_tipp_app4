/// Egy csapat egyszeru statisztikai adatai a tipp-szamitashoz.
class TeamStats {
  final String name;
  final List<String> lastForm; // pl. ['W','W','D','L','W'] legutobbi 5 meccs
  final double avgGoalsScored;
  final double avgGoalsConceded;
  final int leaguePosition;

  const TeamStats({
    required this.name,
    required this.lastForm,
    required this.avgGoalsScored,
    required this.avgGoalsConceded,
    required this.leaguePosition,
  });

  /// Egyszeru forma-pontszam: W=3, D=1, L=0, sullyozva a legutobbi meccsek fele.
  double get formScore {
    double score = 0;
    double weight = 1.0;
    for (final result in lastForm.reversed) {
      final points = result == 'W'
          ? 3.0
          : result == 'D'
              ? 1.0
              : 0.0;
      score += points * weight;
      weight *= 0.85;
    }
    return score;
  }
}

class HeadToHead {
  final int homeWins;
  final int draws;
  final int awayWins;
  final double avgTotalGoals;

  const HeadToHead({
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    required this.avgTotalGoals,
  });
}

class Match {
  final String id;
  final String league;
  final String country;
  final DateTime kickoff;
  final TeamStats home;
  final TeamStats away;
  final HeadToHead h2h;
  final String odds1;
  final String oddsX;
  final String odds2;

  const Match({
    required this.id,
    required this.league,
    required this.country,
    required this.kickoff,
    required this.home,
    required this.away,
    required this.h2h,
    required this.odds1,
    required this.oddsX,
    required this.odds2,
  });
}
