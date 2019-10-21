import 'dart:core';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/utils/stack.dart';

import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

@JsonSerializable()
class Game {
  @JsonKey(
    name: 'playedCards',
    toJson: stackToJson,
    fromJson: stackFromJson,
  )
  final Stack<GameCard> playedCardStack;
  @JsonKey(
    name: 'unplayedCards',
    toJson: stackToJson,
    fromJson: stackFromJson,
  )
  final Stack<GameCard> unplayedCardStack;
  @JsonKey(name: 'players') //, toJson: playerToJson, fromJson: playerFromJson,-
  final List<Player> players;
  @JsonKey(name: 'isPublic', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'maxPlayer', defaultValue: 6)
  final int maxPlayer;
  @JsonKey(name: 'cardAmount', defaultValue: 32)
  final int cardAmount;
  @JsonKey(name: 'name', defaultValue: 'SuperBingo')
  final String name;
  @JsonKey(name: 'id', defaultValue: '')
  final String gameID;
  @JsonKey(name: 'currentPlayerId', defaultValue: '')
  final int currentPlayerId;
  @JsonKey(name: 'state', defaultValue: GameState.waitingForPlayer)
  final GameState state;

  const Game({
    this.gameID = "",
    this.playedCardStack,
    this.unplayedCardStack,
    this.players,
    this.name,
    this.maxPlayer = 6,
    this.isPublic = true,
    this.cardAmount = 32,
    this.currentPlayerId,
    this.state = GameState.waitingForPlayer,
  });

  GameCard get topCard => playedCardStack.first;

  Game copyWith({
    String name,
    String gameId,
    bool isPublic,
    int cardAmount,
    int currentPlayerId,
    int maxPlayer,
    GameState state,
    List<Player> players,
    Stack<GameCard> playedCardStack,
    Stack<GameCard> unplayedCardStack,
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

  Stack<GameCard> shuffleCards({int times}) {
    final cards = playedCardStack.toList();
    for (var i = 0; i < times ?? 1; i++) {
      cards.shuffle();
    }
    return Stack<GameCard>.from(cards);
  }

  void addPlayer(Player player) {
    if (state == GameState.waitingForPlayer && !players.contains(player)) {
      players.add(player);
    }
  }

  void dealCards(int amount) {
    int listIndex = 0;
    for (var i = 0; i < amount; i++) {
      players[listIndex].drawCard(playedCardStack.remove());
      listIndex++;
      if (listIndex == players.length) {
        listIndex = 0;
      }
    }
  }

  List<Player> reversePlayerOrder() => players.reversed;

  static List stackToJson(Stack<GameCard> stack) {
    if (stack != null) {
      return stack.toList().map((gc) => gc.toJson()).toList();
    }
    return [];
  }

  static Stack<GameCard> stackFromJson(List list) {
    print(list);
    final cards = list.map((gc) => GameCard.fromJson(Map<String, dynamic>.from(gc)));
    return Stack.from(cards);
  }

  static playerToJson(List<Player> player) {
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
