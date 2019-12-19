import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:superbingo/models/app_models/card.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:superbingo/service/information_storage.dart';

part 'player.g.dart';

@JsonSerializable()
class Player with EquatableMixin {
  @override
  List<Object> get props => [id, name, cards, isHost];

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
        id: id,
        name: name ?? this.name,
        cards: cards ?? this.cards,
        isHost: isHost ?? this.isHost,
      );

  factory Player.create(String username, {bool isHost = false}) => Player(
        // id: DateTime.now().millisecondsSinceEpoch,
        id: InformationStorage.instance.playerId,
        name: username,
        isHost: isHost,
      );

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as int ?? 0,
        name: json['name'] as String ?? '',
        cards: (json['cards'] as List)
                ?.map((e) => e == null
                    ? null
                    : GameCard.fromJson(Map<String, dynamic>.from(e)))
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

  /// Ruft den Index des Spielers mit der `playerId`,
  /// erhöht dann den Index und gibt den Spieler an diesem
  /// Index zurück.
  ///
  /// Ist der Index gleich dem Ende der Liste, wird der Index wieder auf 0 gesetzt.
  Player getNextPlayer(List<Player> player, [int playerId]) {
    final id = playerId ?? this.id;
    var index = player?.indexWhere((p) => p.id == id) ?? -1;
    if (index + 1 > player.length - 1) {
      index = 0;
    } else {
      index++;
    }
    return player?.elementAt(index);
  }

  /// Ruft den Spieler mit der `playerId` aus der `player` Liste.
  /// Ist keiner Vorhanden wird null zurückgegeben.
  static Player getPlayerFromList(List<Player> player, int playerId) {
    if (player.isEmpty) {
      logWarning(
        '[getPlayerFromList] Player in Game are empty. Can cause problems.',
      );
      return null;
    } else {
      return player.firstWhere((p) => p.id == playerId, orElse: () => null);
    }
  }

  static List cardsToJson(List<GameCard> cards) =>
      cards.map((c) => c.toJson()).toList();
}
