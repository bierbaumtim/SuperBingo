import 'dart:collection';

import 'package:superbingo/models/app_models/card.dart';

import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  @JsonKey(name: 'id', defaultValue: 0)
  final int id;
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
    this.isHost = false,
  }) : cards = cards ?? <GameCard>[];

  Player copyWith({
    String name,
    int cardAmount,
    List<GameCard> cards,
    bool isHost,
  }) =>
      Player(
        id: this.id,
        name: name ?? this.name,
        cards: cards ?? this.cards,
        isHost: isHost ?? this.isHost,
      );

  factory Player.create(String username, {bool isHost = false}) => Player(
        id: DateTime.now().millisecondsSinceEpoch,
        name: username,
        isHost: isHost,
      );

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as int ?? 0,
        name: json['name'] as String ?? '',
        cards: (json['cards'] as List)
                ?.map((e) => e == null ? null : GameCard.fromJson(Map<String, dynamic>.from(e)))
                ?.toList() ??
            [],
        isHost: json['isHost'] as bool ?? false,
      );

  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  void drawCard(GameCard card) => cards.add(card);

  void drawCards(Queue<GameCard> cards, {int amount = 6}) {
    for (var i = 0; i < amount - 1; i++) {
      drawCard(cards.removeFirst());
    }
  }

  static List cardsToJson(List<GameCard> cards) => cards.map((c) => c.toJson()).toList();
}
