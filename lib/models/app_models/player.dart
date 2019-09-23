import 'package:superbingo/models/app_models/card.dart';

class Player {
  int id, cardAmount;
  String name;
  List<GameCard> cards;

  Player({
    this.id,
    this.name,
    this.cards,
    this.cardAmount,
  });

  Future<String> drawCard(GameCard card) async {
    cards.add(card);
  }

  Player fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as int,
        name: json['name'] as String,
        cardAmount: json['cardAmount'] as int,
      );

  Map<String, dynamic> toNetworkJson() => {
        'id': id,
        'name': name,
        'cardAmount': cards.length,
      };
}
