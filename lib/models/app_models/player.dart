import 'package:superbingo/models/app_models/card.dart';

class Player {
  int id;
  String name;
  List<Card> cards;

  Player({this.id, this.name, this.cards}) {}

  Future<bool> createGame() async {}

  Future<String> playCard(Card card) async {}

  Future<String> drawCard(Card card) async {
    cards.add(card);
  }

  Future<String> randomizeCards() async {}
}
