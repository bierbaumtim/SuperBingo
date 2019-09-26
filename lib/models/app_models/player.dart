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
  @JsonKey(name: 'cards', defaultValue: <GameCard>[])
  final List<GameCard> cards;
  @JsonKey(name: 'isHost', defaultValue: false)
  final bool isHost;

  const Player({
    this.id,
    this.name,
    this.cards,
    this.cardAmount,
    this.isHost = false,
  });

  Player copyWith({String name, int cardAmount, List<GameCard> cards}) => Player(
        id: this.id,
        name: name ?? this.name,
        cards: cards ?? this.cards,
        cardAmount: cardAmount ?? this.cardAmount,
      );

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  void drawCard(GameCard card) => cards.add(card);
}
