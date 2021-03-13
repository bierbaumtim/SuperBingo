import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../services/information_storage.dart';
import 'card.dart';

part 'player.g.dart';

/// {@template player}
/// Datenhaltungsklasse für einen Spieler
///
/// Stellt Datenbank-relevate Methoden bereit.
/// Stellt Methoden bereit um Karten zu ziehen und den nächsten Spieler zu ermitteln.
/// {@endtemplate}
@JsonSerializable(explicitToJson: true)
class Player with EquatableMixin {
  @override
  List<Object> get props => [
        id,
        name,
        cards,
        isHost,
        finishPosition,
      ];

  /// ID des Spielers.
  ///
  /// Pro Spiel einzigartig
  @JsonKey(name: 'id', defaultValue: '')
  final String id;

  /// Name des Spielers
  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  /// Liste des Spielers - Kartenhand
  @JsonKey(name: 'cards', defaultValue: <GameCard>[])
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
    required this.id,
    required this.name,
    this.isHost = false,
    this.finishPosition = 0,
    List<GameCard>? cards,
  }) : cards = cards ?? <GameCard>[];

  /// Überschreibt aktuelles Object mit bestimmten neuen Werten
  Player copyWith({
    String? name,
    int? cardAmount,
    int? finishPosition,
    List<GameCard>? cards,
    bool? isHost,
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
      );

  /// Factory um einen Datenbanksatz in ein `Player`-Object umzuwandeln
  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

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

  /// Ruft den Spieler mit der `playerId` aus der `player` Liste.
  /// Ist keiner Vorhanden wird null zurückgegeben.
  static Player? getPlayerFromList(List<Player> player, String playerId) {
    if (player.isEmpty) {
      // LogService.instance.log(
      //   '[getPlayerFromList] Player in Game are empty. Can cause problems.',
      // );
      return null;
    } else {
      try {
        return player.firstWhere((p) => p.id == playerId);
      } catch (e) {
        return null;
      }
    }
  }
}
