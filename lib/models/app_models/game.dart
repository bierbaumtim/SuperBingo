import 'dart:collection';
import 'dart:convert';
import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:supercharged/supercharged.dart';

import '../../constants/enums.dart';
import 'card.dart';
import 'player.dart';

part 'game.g.dart';

/// {@template game}
/// Datenhaltungsklasse für ein Spiel.
/// {@endtemplate}
@JsonSerializable(explicitToJson: true)
class Game with EquatableMixin {
  @override
  bool get stringify => true;

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

  /// Konfiguration, ob das Spiel öffentlich sichtbar sein soll
  /// und jeder diesem Spiel beitreten kann.
  ///
  /// Bei `true`, ist das Spiel öffentlich sichtbar und jeder Spieler kann diesem Spiel beitreten,
  /// solange die maximal Spieleranzahl nicht erreicht ist
  ///
  /// Bei `false`, ist das Spiel nicht öffentlich sichbar
  /// und ein Spieler kann nur mit dem zum Spiel gehörenden Link joinen.
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

  /// Menge der Karten die gezogen werden muss.
  ///
  /// Default: 1
  @JsonKey(name: 'cardDrawAmount', defaultValue: 1)
  int cardDrawAmount;

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

  /// Erlaubte Kartenfarbe.
  /// Wird gesetzt wenn man einen Buben oder Joker genutzt hat.
  @JsonKey(name: 'allowedCardColor')
  CardColor allowedCardColor;

  /// Parameter ob ein Bube oder Joker gelegt werden darf.
  /// Wird gesetzt wenn ein Bube oder Joker genutzt wurde.
  @JsonKey(name: 'isJokerOrJackAllowed', defaultValue: true)
  bool isJokerOrJackAllowed;

  @JsonKey(name: 'message', defaultValue: '')
  String message;

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
    this.cardDrawAmount,
    this.allowedCardColor,
    this.isJokerOrJackAllowed,
    this.state = GameState.waitingForPlayer,
    this.message,
  }) : playedCardStack = playedCardStack ?? Queue<GameCard>.from(<GameCard>[]);

  /// Oberste Karte des Stapels der gespielten Karten
  GameCard get topCard => playedCardStack.lastOrNull();

  List<GameCard> get playedCards => playedCardStack.toList();

  List<GameCard> get unplayedCards => unplayedCardStack.toList();

  /// Spiel wird aktuell gespielt
  bool get isRunning => state == GameState.active;

  bool get isCompleted => state == GameState.gameCompleted;

  String get link => 'superbingo://id:$gameID|name:$name';

  /// Überschreibt aktuelles Object mit bestimmten neuen Werten
  Game copyWith({
    String name,
    String gameId,
    bool isPublic,
    bool isJokerOrJackAllowed,
    int cardAmount,
    int cardDrawAmount,
    int maxPlayer,
    String currentPlayerId,
    GameState state,
    CardColor allowedCardColor,
    List<Player> players,
    Queue<GameCard> playedCardStack,
    Queue<GameCard> unplayedCardStack,
  }) =>
      Game(
        name: name ?? this.name,
        cardAmount: cardAmount ?? this.cardAmount,
        cardDrawAmount: cardDrawAmount ?? this.cardDrawAmount,
        isPublic: isPublic ?? this.isPublic,
        gameID: _fillGameId(gameId),
        maxPlayer: maxPlayer ?? this.maxPlayer,
        players: players ?? this.players,
        playedCardStack: playedCardStack ?? this.playedCardStack,
        unplayedCardStack: unplayedCardStack ?? this.unplayedCardStack,
        currentPlayerId: currentPlayerId ?? this.currentPlayerId,
        state: state ?? this.state,
        isJokerOrJackAllowed: isJokerOrJackAllowed ?? this.isJokerOrJackAllowed,
        allowedCardColor: allowedCardColor ?? this.allowedCardColor,
      );

  /// Wandelt ein [Game]-Object in eine Datenbank-kompatible Map um
  Map<String, dynamic> toJson() => _$GameToJson(this);

  /// json wird in eine [Game] Object umgewandelt
  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  /// [Game] Object wird in eine Datenbank-kompatible Map umgewandelt
  static Map<String, dynamic> toDBData(Game game) {
    final json = jsonEncode(game);
    return jsonDecode(json) as Map<String, dynamic>;
  }

  void start() {
    dealCards(6);
    state = GameState.active;
    currentPlayerId = players.first.id;
  }

  /// Mischt die Karten. Wie häufig gemischt wird, wird mit `times` übergeben
  void shuffleCards({int times = 1}) {
    assert(times != null);
    final cards = unplayedCardStack.toList();
    for (var i = 0; i < times; i++) {
      cards.shuffle();
    }
    unplayedCardStack = Queue<GameCard>.from(cards);
  }

  /// Fügt den neuen `player` zur Liste `players` der Spieler hinzu
  void addPlayer(Player player) {
    if ([GameState.waitingForPlayer, GameState.created].contains(state) &&
        !players.contains(player)) {
      players.add(player);
    }
  }

  /// Löscht den `player` aus der List der Spieler `players`
  void removePlayer(Player player) {
    players.removeWhere((p) => p.id == player.id);
    if (!players.contains(player)) {
      final playerCards = player.cards..shuffle();
      unplayedCardStack.addAll(playerCards);
    }
  }

  /// Die Karten werden an die Spieler verteilt.
  /// Die Menge pro Spieler wird mit `amount` übergeben.
  void dealCards(int amount) {
    for (var i = 0; i < amount; i++) {
      for (final player in players) {
        player.drawCard(unplayedCardStack.removeFirst());
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

  void cleanUpCardStacks() {
    final activeCards = playedCardStack.toList().reversed.toList();
    final cards = activeCards.sublist(5);
    playedCardStack = Queue<GameCard>.from(
      activeCards.take(5).toList().reversed,
    );
    for (var i = 0; i < 5; i++) {
      cards.shuffle();
    }
    unplayedCardStack.addAll(cards);
  }

  /// Wandelt cardStacks in Datenbank-kompatible Listen von [GameCard] Map Repräsentationen um
  static List<Map<String, dynamic>> stackToJson(Queue<GameCard> stack) {
    return stack?.toList()?.map((gc) => gc.toJson())?.toList() ??
        <Map<String, dynamic>>[];
  }

  /// Wandelt ein List eines Datensatzes in eine Queue von [GameCard]-Ojects um
  static Queue<GameCard> stackFromJson(List list) {
    final cards = list?.map<GameCard>(
            (gc) => GameCard.fromJson(Map<String, dynamic>.from(gc))) ??
        <GameCard>[];
    return Queue.from(cards);
  }

  String _fillGameId(String nGameId) {
    if (gameID != null && gameID.isNotEmpty) {
      return nGameId;
    }
    return gameID;
  }
}

enum GameState {
  /// Das Spiel wurde erstellt, aber es können noch keine Spieler dem Spiel beitreten.
  created,

  /// Lobby des Spiels, es wird auf weitere Spieler gewartet, damit das Spiel gestartet werden kann.
  waitingForPlayer,

  /// Das Spiel wird aktuell gespielt. Es können keine weiteren Spieler mehr joinen
  active,

  /// Das Spiel ist abgeschlossen. Es kann nun komplett beendet und neugestartet werden.
  gameCompleted,

  /// Das Spiel wurde vom Host beendet.
  finished,
}
