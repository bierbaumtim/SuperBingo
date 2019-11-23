import 'dart:collection';
import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/player.dart';

import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

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

  @JsonKey(
    name: 'playedCards',
    toJson: stackToJson,
    fromJson: stackFromJson,
  )
  Queue<GameCard> playedCardStack;
  @JsonKey(
    name: 'unplayedCards',
    toJson: stackToJson,
    fromJson: stackFromJson,
  )
  Queue<GameCard> unplayedCardStack;
  @JsonKey(name: 'players') //, toJson: playerToJson, fromJson: playerFromJson,-
  List<Player> players;
  @JsonKey(name: 'isPublic', defaultValue: true)
  bool isPublic;
  @JsonKey(name: 'maxPlayer', defaultValue: 6)
  int maxPlayer;
  @JsonKey(name: 'cardAmount', defaultValue: 32)
  int cardAmount;
  @JsonKey(name: 'name', defaultValue: 'SuperBingo')
  String name;
  @JsonKey(name: 'id', defaultValue: '')
  final String gameID;
  @JsonKey(name: 'currentPlayerId', defaultValue: '')
  int currentPlayerId;
  @JsonKey(name: 'state', defaultValue: GameState.waitingForPlayer)
  GameState state;

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
  }) : playedCardStack = playedCardStack ?? Queue<GameCard>.from([]);

  GameCard get topCard => playedCardStack.isEmpty ? null : playedCardStack.first;

  Game copyWith({
    String name,
    String gameId,
    bool isPublic,
    int cardAmount,
    int currentPlayerId,
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

  Map<String, dynamic> toJson() => _$GameToJson(this);

  // factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        gameID: json['id'] as String ?? '',
        playedCardStack: Game.stackFromJson(json['playedCards'] as List),
        unplayedCardStack: Game.stackFromJson(json['unplayedCards'] as List),
        players: (json['players'] as List)
            ?.map((e) => e == null ? null : Player.fromJson(Map<String, dynamic>.from(e)))
            ?.toList(),
        name: json['name'] as String ?? 'SuperBingo',
        maxPlayer: json['maxPlayer'] as int ?? 6,
        isPublic: json['isPublic'] as bool ?? true,
        cardAmount: json['cardAmount'] as int ?? 32,
        currentPlayerId: json['currentPlayerId'] as int ?? 0,
        state: _$enumDecodeNullable(_$GameStateEnumMap, json['state']) ?? GameState.waitingForPlayer,
      );

  void shuffleCards({int times}) {
    final cards = playedCardStack.toList();
    for (var i = 0; i < times ?? 1; i++) {
      cards.shuffle();
    }
    playedCardStack = Queue<GameCard>.from(cards);
  }

  void addPlayer(Player player) {
    if (state == GameState.waitingForPlayer && !players.contains(player)) {
      players.add(player);
    }
  }

  void removePlayer(Player player) {
    players.removeWhere((p) => p.id == player.id);
    if (!players.contains(player)) {
      final playerCards = player.cards..shuffle();
      final unplayedCards = unplayedCardStack;
      unplayedCards.addAll(playerCards);
    }
  }

  void dealCards(int amount) {
    for (var i = 0; i < amount - 1; i++) {
      for (var k = 0; k < players.length - 1; k++) {
        players[k].drawCard(playedCardStack.removeFirst());
      }
    }
  }

  List<Player> reversePlayerOrder() => players.reversed;

  static List stackToJson(Queue<GameCard> stack) {
    if (stack != null) {
      return stack.toList().map((gc) => gc.toJson()).toList();
    }
    return [];
  }

  static Queue<GameCard> stackFromJson(List list) {
    final cards = list.map((gc) => GameCard.fromJson(Map<String, dynamic>.from(gc)));
    return Queue.from(cards);
  }

  static List playerToJson(List<Player> player) {
    if (player != null) {
      return player.map((p) => p.toJson()).toList();
    }
    return [];
  }

  static List<Player> playerFromJson(List list) {
    return list.map((p) => Player.fromJson(Map<String, dynamic>.from(p))).toList();
  }

  String _fillGameId(String nGameId) {
    if (gameID == null) return nGameId;
    if (gameID.isEmpty) return nGameId;
    return gameID;
  }
}

enum GameState { waitingForPlayer, active, gameCompleted }
