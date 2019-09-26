import 'package:json_annotation/json_annotation.dart';

part 'card.g.dart';

@JsonSerializable()
class GameCard {
  @JsonKey(name: 'color', fromJson: cardColorFromJson)
  final CardColor color;
  @JsonKey(name: 'number')
  final CardNumber number;
  final SpecialRule rule;

  GameCard({this.color, this.number}) : rule = ruleFromNumber(number);

  factory GameCard.fromDefinitonString(String definition) {
    final parts = definition.split('|');

    return GameCard();
  }

  factory GameCard.fromJson(Map<String, dynamic> json) => null;

  Map<String, dynamic> toJson() => null;

  static SpecialRule ruleFromNumber(CardNumber number) {
    switch (number) {
      case CardNumber.eight:
        return SpecialRule.skip;
      case CardNumber.nine:
        return SpecialRule.reverse;
      case CardNumber.jack:
      case CardNumber.joker:
        return SpecialRule.joker;
      case CardNumber.seven:
        return SpecialRule.plusTwo;
      default:
        return null;
    }
  }

  static cardColorFromJson(String json) => CardColor.values.firstWhere((c) => c.toString() == json);
}

enum CardColor { heart, diamond, spade, clover }
enum CardNumber { five, six, seven, eight, nine, jack, queen, king, ace, joker }
enum SpecialRule { reverse, skip, joker, plusTwo }
