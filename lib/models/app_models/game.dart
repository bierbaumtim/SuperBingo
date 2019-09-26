import 'dart:core';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/utils/stack.dart';

import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

@JsonSerializable()
class Game {
  @JsonKey(name: 'playedCards', toJson: stackToJson, fromJson: stackFromJson)
  final Stack<GameCard> playedCardStack;
  @JsonKey(name: 'unplayedCards', toJson: stackToJson, fromJson: stackFromJson)
  final Stack<GameCard> unplayedCardStack;
  @JsonKey(name: 'players', defaultValue: <Player>[])
  final List<Player> players;
  @JsonKey(name: 'isGameRunning', defaultValue: false)
  final bool isGameRunning;
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

  const Game({
    this.gameID,
    this.playedCardStack,
    this.unplayedCardStack,
    this.players,
    this.name,
    this.maxPlayer = 6,
    this.isPublic,
    this.cardAmount = 32,
    this.isGameRunning = false,
  });

  GameCard get topCard => playedCardStack.first;

  Game copyWith({
    String name,
    String gameId,
    bool isPublic,
    bool isGameRunning,
    int cardAmount,
    int maxPlayer,
    List<Player> players,
    Stack<GameCard> playedCardStack,
    Stack<GameCard> unplayedCardStack,
  }) =>
      Game(
        name: name ?? this.name,
        cardAmount: cardAmount ?? this.cardAmount,
        isGameRunning: isGameRunning ?? this.isGameRunning,
        isPublic: isPublic ?? this.isPublic,
        gameID: _fillGameId(gameId),
        maxPlayer: maxPlayer ?? this.maxPlayer,
        players: players ?? this.players,
        playedCardStack: playedCardStack ?? this.playedCardStack,
        unplayedCardStack: unplayedCardStack ?? this.unplayedCardStack,
      );

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  Map<String, dynamic> toJson() => _$GameToJson(this);

  Stack<GameCard> shuffleCards({int times}) {
    final cards = playedCardStack.toList();
    for (var i = 0; i < times ?? 1; i++) {
      cards.shuffle();
    }
    return Stack<GameCard>.from(cards);
  }

  void addPlayer(Player player) {
    if (!isGameRunning) {
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

  static stackToJson(Stack<GameCard> stack) {
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

  String _fillGameId(String nGameId) {
    if (gameID == null) return nGameId;
    if (gameID.isEmpty) return nGameId;
    return gameID;
  }
}
