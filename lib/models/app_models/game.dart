import 'dart:core';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/utils/stack.dart';

class Game {
  Stack<GameCard> cardStack;
  List<Player> players;
  Player self;
  bool isGameRunning, public;
  int maxPlayer, cardAmount;
  String name;

  Game({
    this.name,
    this.maxPlayer,
    this.public,
    this.cardAmount,
    this.isGameRunning = false,

  });

  GameCard get topCard => cardStack.first;

  Future<bool> startGame() async {
    isGameRunning = true;
  }

  Map<String, dynamic> toNetworkJson() => {
        'isGameRunning': isGameRunning,
        'public': public,
        'maxPlayer': maxPlayer,
        'name': name,
      };

  void shuffleCards({int times}) {
    final cards = cardStack.toList();
    for (var i = 0; i < times ?? 1; i++) {
      cards.shuffle();
    }
    cardStack.fromList(cards);
  }

  void addPlayer(Player player) {
    if (!isGameRunning) {
      players.add(player);
    }
  }

  void dealCards(int amount) {
    int listIndex = 0;
    for (var i = 0; i < amount; i++) {
      players[listIndex].drawCard(cardStack.remove());
      listIndex++;
      if (listIndex == players.length) {
        listIndex = 0;
      }
    }
  }

  void reversePlayerOrder() => players = players.reversed;
}
