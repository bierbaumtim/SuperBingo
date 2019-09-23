import 'package:superbingo/models/app_models/card.dart';

class Rules {
  static final Rules instance = Rules._internal();

  factory Rules() => instance;

  Rules._internal();

  static isCardAllowed(GameCard card, GameCard topCard) =>
      card.color == topCard.color || card.number == topCard.number;
}
