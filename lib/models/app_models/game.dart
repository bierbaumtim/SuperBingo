import 'package:super_bingo/models/app_models/card.dart';
import 'package:super_bingo/models/app_models/player.dart';
import 'package:super_bingo/utils/stack.dart';

class Game {
  Stack<Card> cardStack;
  List<Player> players;

  Card get topCard => cardStack.first;

  Future<bool> startGame() async {}
}
