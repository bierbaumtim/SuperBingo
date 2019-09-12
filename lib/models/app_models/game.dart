import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/utils/stack.dart';

class Game {
  Stack<Card> cardStack;
  List<Player> players;

  Card get topCard => cardStack.first;

  Future<bool> startGame() async {}

  Map<String, dynamic> toNetworkJson() => {};
}
