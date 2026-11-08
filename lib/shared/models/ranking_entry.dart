class RankingEntry {
  const RankingEntry({
    required this.rank,
    required this.name,
    required this.score,
    this.isYou = false,
    this.isFriend = false,
  });

  final int rank;
  final String name;
  final int score;
  final bool isYou;
  final bool isFriend;

  factory RankingEntry.fromJson(Map<String, dynamic> json, {int rank = 0}) => RankingEntry(
        rank: (json['rank'] as num?)?.toInt() ?? rank,
        name: json['name'] as String? ?? 'Player',
        score: (json['score'] as num?)?.toInt() ?? 0,
        isFriend: json['friend'] as bool? ?? false,
      );

  RankingEntry copyWith({int? rank, bool? isYou}) => RankingEntry(
        rank: rank ?? this.rank,
        name: name,
        score: score,
        isYou: isYou ?? this.isYou,
        isFriend: isFriend,
      );
}
