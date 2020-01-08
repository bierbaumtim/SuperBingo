import 'dart:collection';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/service/information_storage.dart';

import 'package:equatable/equatable.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:supercharged/supercharged.dart';

part 'player.g.dart';

/// {@template player}
/// Datenhaltungsklasse für einen Spieler
///
/// Stellt Datenbank-relevate Methoden bereit.
/// Stellt Methoden bereit um Karten zu ziehen und den nächsten Spieler zu ermitteln.
/// {@endtemplate}
@JsonSerializable()
class Player with EquatableMixin {
  @override
  List<Object> get props => [id, name, cards, isHost];

  /// ID des Spielers.
  ///
  /// Pro Spiel einzigartig
  @JsonKey(name: 'id', defaultValue: '')
  final String id;

  /// Name des Spielers
  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  /// Liste des Spielers - Kartenhand
  @JsonKey(name: 'cards', defaultValue: <GameCard>[]) //, toJson: cardsToJson
  final List<GameCard> cards;

  /// Konfiguration, ob der Spieler der Host ist.
  ///
  /// Der Host-Client übernimmt Aufgaben, wie das Karten mischen, verteilen
  @JsonKey(name: 'isHost', defaultValue: false)
  final bool isHost;

  @JsonKey(name: 'finishPosition', defaultValue: 0)
  final int finishPosition;

  /// {@macro player}
  Player({
    this.id,
    this.name,
    this.isHost = false,
    this.finishPosition = 0,
    List<GameCard> cards,
  }) : cards = cards ?? <GameCard>[];

  /// Überschreibt aktuelles Object mit bestimmten neuen Werten
  Player copyWith({
    String name,
    int cardAmount,
    int finishPosition,
    List<GameCard> cards,
    bool isHost,
  }) =>
      Player(
        id: id,
        name: name ?? this.name,
        cards: cards ?? this.cards,
        isHost: isHost ?? this.isHost,
        finishPosition: finishPosition ?? this.finishPosition,
      );

  /// Factory, um ein neues [Player]-Object zu erstellen, ohne das die `id` übergeben werden muss
  factory Player.create(String username, {bool isHost = false}) => Player(
        id: InformationStorage.instance.playerId,
        name: username,
        isHost: isHost,
        finishPosition: 0,
      );

  /// Factory um einen Datenbanksatz in ein `Player`-Object umzuwandeln
  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String ?? '',
        name: json['name'] as String ?? '',
        cards: (json['cards'] as List)
                ?.map((e) => e == null
                    ? null
                    : GameCard.fromJson(Map<String, dynamic>.from(e)))
                ?.toList() ??
            [],
        isHost: json['isHost'] as bool ?? false,
        finishPosition: json['finishPosition'] as int ?? 0,
      );

  /// Wandelt ein `Player`-Object in eine Datenbank-kompatible Map um
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  /// Fügt eine Karte `card` der Kartenhand `cards` hinzu
  void drawCard(GameCard card) => cards.add(card);

  /// Fügt die durch `amount` vorgebene Anzahl an Karten vom Kartenstapel `cardStack` der Kartenhand `cards` hinzu
  void drawCards(Queue<GameCard> cardStack, {int amount = 6}) {
    for (var i = 0; i < amount; i++) {
      drawCard(cardStack.removeFirst());
    }
  }

  /// Ruft den Index des Spielers mit der `playerId`,
  /// erhöht dann den Index und gibt den Spieler an diesem
  /// Index zurück.
  ///
  /// Ist der Index gleich dem Ende der Liste, wird der Index wieder auf 0 gesetzt.
  Player getNextPlayer(
    List<Player> player, {
    String playerId,
    bool skipNextPlayer = false,
  }) {
    final id = playerId ?? this.id;
    assert(player != null);
    assert(id != null);
    final activePlayer =
        player.filter((player) => player.finishPosition == 0).toList();
    var index = activePlayer.indexWhere((p) => p.id == id) ?? -1;
    index = skipNextPlayer ? index + 2 : index + 1;
    if (index > activePlayer.length - 1) {
      index = 0;
    }
    return activePlayer.elementAtOrNull(index);
  }

  /// Ruft den Spieler mit der `playerId` aus der `player` Liste.
  /// Ist keiner Vorhanden wird null zurückgegeben.
  static Player getPlayerFromList(List<Player> player, String playerId) {
    if (player.isEmpty) {
      logWarning(
        '[getPlayerFromList] Player in Game are empty. Can cause problems.',
      );
      return null;
    } else {
      return player.firstWhere((p) => p.id == playerId, orElse: () => null);
    }
  }

  /// Wandelt eine List an Spielkarten `cards` in eine List mit Datenbank-kompatiblen [GameCard]-Objecten um
  static List cardsToJson(List<GameCard> cards) =>
      cards.map((c) => c.toJson()).toList();
}
