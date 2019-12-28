import 'dart:collection';
import 'dart:convert';
import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/player.dart';

import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

/// {@template game}
/// Datenhaltungsklasse für ein Spiel.
/// {@endtemplate}
@JsonSerializable()
class Game with EquatableMixin {
  @override
  List<Object> get props => [
        playedCardStack,
        unplayedCardStack,
        players,
        isPublic,
        maxPlayer,
        name,
        currentPlayerId,
        state,
      ];

  /// Stapel der gespielten Karten
  @JsonKey(
    name: 'playedCards',
    toJson: stackToJson,
    fromJson: stackFromJson,
  )
  Queue<GameCard> playedCardStack;

  /// Stapel der ungespielten Karten - Nachziehstapel
  @JsonKey(
    name: 'unplayedCards',
    toJson: stackToJson,
    fromJson: stackFromJson,
  )
  Queue<GameCard> unplayedCardStack;

  /// List der Spieler
  @JsonKey(name: 'players')
  List<Player> players;

  /// Konfiguration, ob das Spiel öffentlich sichtbar sein soll und jeder diesem Spiel beitreten kann.
  ///
  /// Bei `true`, ist das Spiel öffentlich sichtbar und jeder Spieler kann diesem Spiel beitreten, solange die maximal Spieleranzahl
  /// nicht erreicht ist
  ///
  /// Bei `false`, ist das Spiel nicht öffentlich sichbar und ein Spieler kann nur mit dem zum Spiel gehörenden Link joinen.
  ///
  /// Default: true
  @JsonKey(name: 'isPublic', defaultValue: true)
  bool isPublic;

  /// Konfiguration, wie viele Spieler maximal in diesem Spiel mitspielen können.
  ///
  /// Default: 6
  @JsonKey(name: 'maxPlayer', defaultValue: 6)
  int maxPlayer;

  /// Konfiguration mit wie vielen Karten gespielt werden soll.
  ///
  /// Default: 32
  @JsonKey(name: 'cardAmount', defaultValue: 32)
  int cardAmount;

  /// Konfiguration, unter welchem Namen das Spiel sichtbar sein soll. Kann auch zur Suche eines Spiels genutzt werden.
  @JsonKey(name: 'name', defaultValue: 'SuperBingo')
  String name;

  /// Firestore Document-ID, die eindeutig auf ein Spiel-Datensatz in der Datenbank verweist
  @JsonKey(name: 'id', defaultValue: '')
  final String gameID;

  /// Id des Spielers der aktuell an der Reihe ist
  @JsonKey(name: 'currentPlayerId', defaultValue: '')
  String currentPlayerId;

  /// States Spiels
  @JsonKey(name: 'state', defaultValue: GameState.waitingForPlayer)
  GameState state;

  /// {@macro game}
  Game({
    this.gameID = "",
    Queue<GameCard> playedCardStack,
    this.unplayedCardStack,
    this.players,
    this.name,
    this.maxPlayer = 6,
    this.isPublic = true,
    this.cardAmount = 32,
    this.currentPlayerId,
    this.state = GameState.waitingForPlayer,
  }) : playedCardStack = playedCardStack ?? Queue<GameCard>.from(<GameCard>[]);

  /// Oberste Karte des Stapels der gespielten Karten
  GameCard get topCard => playedCardStack.isEmpty ? null : playedCardStack.last;

  /// Spiel wird aktuell gespielt
  bool get isRunning => state == GameState.active;

  /// Überschreibt aktuelles Object mit bestimmten neuen Werten
  Game copyWith({
    String name,
    String gameId,
    bool isPublic,
    int cardAmount,
    String currentPlayerId,
    int maxPlayer,
    GameState state,
    List<Player> players,
    Queue<GameCard> playedCardStack,
    Queue<GameCard> unplayedCardStack,
  }) =>
      Game(
        name: name ?? this.name,
        cardAmount: cardAmount ?? this.cardAmount,
        isPublic: isPublic ?? this.isPublic,
        gameID: _fillGameId(gameId),
        maxPlayer: maxPlayer ?? this.maxPlayer,
        players: players ?? this.players,
        playedCardStack: playedCardStack ?? this.playedCardStack,
        unplayedCardStack: unplayedCardStack ?? this.unplayedCardStack,
        currentPlayerId: currentPlayerId ?? this.currentPlayerId,
        state: state ?? this.state,
      );

  /// Wandelt ein [Game]-Object in eine Datenbank-kompatible Map um
  Map<String, dynamic> toJson() => _$GameToJson(this);

  /// json wird in eine [Game] Object umgewandelt
  factory Game.fromJson(Map<String, dynamic> json) => Game(
        gameID: json['id'] as String ?? '',
        playedCardStack: Game.stackFromJson(json['playedCards'] as List),
        unplayedCardStack: Game.stackFromJson(json['unplayedCards'] as List),
        players: (json['players'] as List)
            ?.map((e) => e == null
                ? null
                : Player.fromJson(Map<String, dynamic>.from(e)))
            ?.toList(),
        name: json['name'] as String ?? 'SuperBingo',
        maxPlayer: json['maxPlayer'] as int ?? 6,
        isPublic: json['isPublic'] as bool ?? true,
        cardAmount: json['cardAmount'] as int ?? 32,
        currentPlayerId: json['currentPlayerId'] as String ?? '',
        state: _$enumDecodeNullable(_$GameStateEnumMap, json['state']) ??
            GameState.waitingForPlayer,
      );

  /// [Game] Object wird in eine Datenbank-kompatible Map umgewandelt
  static Map<String, dynamic> toDBData(Game game) {
    final json = jsonEncode(game);
    return jsonDecode(json) as Map<String, dynamic>;
  }

  /// Mischt die Karten. Wie häufig gemischt wird, wird mit `times` übergeben
  void shuffleCards({int times = 1}) {
    assert(times != null);
    final cards = playedCardStack
        .toList(); // TODO überprüfen ob hier der richtige Stapel gemischt wird
    for (var i = 0; i < times; i++) {
      cards.shuffle();
    }
    playedCardStack = Queue<GameCard>.from(cards);
  }

  /// Fügt den neuen `player` zur Liste `players` der Spieler hinzu
  void addPlayer(Player player) {
    if (state == GameState.waitingForPlayer && !players.contains(player)) {
      players.add(player);
    }
  }

  /// Löscht den `player` aus der List der Spieler `players`
  void removePlayer(Player player) {
    players.removeWhere((p) => p.id == player.id);
    if (!players.contains(player)) {
      final playerCards = player.cards..shuffle();
      final unplayedCards = unplayedCardStack;
      unplayedCards.addAll(playerCards);
    }
  }

  /// Die Karten werden an die Spieler verteilt.
  /// Die Menge pro Spieler wird mit `amount` übergeben.
  void dealCards(int amount) {
    for (var i = 0; i < amount - 1; i++) {
      for (var k = 0; k < players.length - 1; k++) {
        players[k].drawCard(playedCardStack.removeFirst());
      }
    }
  }

  /// Aktualisiert den `player` in der Liste der Spieler `players`
  void updatePlayer(Player newPlayer) {
    players = players
        .map((player) => player.id == newPlayer.id ? newPlayer : player)
        .toList();
  }

  /// dreht die Spielrichtung um
  List<Player> reversePlayerOrder() => players.reversed.toList();

  /// Wandelt cardStacks in Datenbank-kompatible Listen von [GameCard] Map Repräsentationen um
  static List<Map<String, dynamic>> stackToJson(Queue<GameCard> stack) {
    if (stack != null) {
      return stack.toList().map((gc) => gc.toJson()).toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// Wandelt ein List eines Datensatzes in eine Queue von [GameCard]-Ojects um
  static Queue<GameCard> stackFromJson(List list) {
    final cards =
        list.map((gc) => GameCard.fromJson(Map<String, dynamic>.from(gc)));
    return Queue.from(cards);
  }

  /// wandelt die Liste der Spieler `player` in eine Datenbank-kompatible Liste um
  static List playerToJson(List<Player> player) {
    if (player != null) {
      return player.map((p) => p.toJson()).toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// Wandelt ein List eines Datensatzes in eine Liste von [Player]-Ojects um
  static List<Player> playerFromJson(List list) {
    return list
        .map<Player>((p) => Player.fromJson(Map<String, dynamic>.from(p)))
        .toList();
  }

  String _fillGameId(String nGameId) {
    if (gameID == null) return nGameId;
    if (gameID.isEmpty) return nGameId;
    return gameID;
  }
}

enum GameState {
  /// Lobby des Spiels, es wird auf weitere Spieler gewartet, damit das Spiel gestartet werden kann.
  waitingForPlayer,

  /// Das Spiel wird aktuell gespielt. Es können keine weiteren Spieler mehr joinen
  active,

  /// Das Spiel ist abgeschlossen. Es kann nun komplett beendet und neugestartet werden.
  gameCompleted,

  /// Das Spiel wurde vom Host beendet.
  finished,
}
