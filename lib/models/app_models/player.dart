import 'package:superbingo/models/app_models/card.dart';

import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  @JsonKey(name: 'id', defaultValue: 0)
  final int id;
  @JsonKey(name: 'cardamount', defaultValue: 32)
  final int cardAmount;
  @JsonKey(name: 'name', defaultValue: '')
  final String name;
  @JsonKey(name: 'cards', defaultValue: <GameCard>[]) //, toJson: cardsToJson
  final List<GameCard> cards;
  @JsonKey(name: 'isHost', defaultValue: false)
  final bool isHost;

  Player({
    this.id,
    this.name,
    List<GameCard> cards,
    this.cardAmount,
    this.isHost = false,
  }) : cards = cards ?? <GameCard>[];

  Player copyWith({String name, int cardAmount, List<GameCard> cards}) => Player(
        id: this.id,
        name: name ?? this.name,
        cards: cards ?? this.cards,
        cardAmount: cardAmount ?? this.cardAmount,
      );

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as int ?? 0,
        name: json['name'] as String ?? '',
        cards: (json['cards'] as List)
                ?.map((e) => e == null ? null : GameCard.fromJson(Map<String, dynamic>.from(e)))
                ?.toList() ??
            [],
        cardAmount: json['cardamount'] as int ?? 32,
        isHost: json['isHost'] as bool ?? false,
      );

  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  void drawCard(GameCard card) => cards.add(card);

  static List cardsToJson(List<GameCard> cards) => cards.map((c) => c.toJson()).toList();
}
