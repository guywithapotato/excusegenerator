enum AppLanguage { tr, en }

enum ExcuseRarity { common, rare, epic, legendary }

class Excuse {
  const Excuse({
    required this.id,
    required this.language,
    required this.category,
    required this.text,
    required this.rarity,
  });

  final String id;
  final AppLanguage language;
  final String category;
  final String text;
  final ExcuseRarity rarity;
}

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.excuseId,
    required this.text,
    required this.category,
    required this.rarity,
    required this.createdAt,
  });

  final String id;
  final String excuseId;
  final String text;
  final String category;
  final ExcuseRarity rarity;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'excuseId': excuseId,
        'text': text,
        'category': category,
        'rarity': rarity.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, Object?> json) => HistoryEntry(
        id: json['id'] as String,
        excuseId: json['excuseId'] as String,
        text: json['text'] as String,
        category: json['category'] as String,
        rarity: ExcuseRarity.values.byName(json['rarity'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
