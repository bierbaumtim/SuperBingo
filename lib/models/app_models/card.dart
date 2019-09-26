import 'package:json_annotation/json_annotation.dart';

part 'card.g.dart';

@JsonSerializable()
class GameCard {
  @JsonKey(
    name: 'color',
    fromJson: cardColorFromJson,
    toJson: cardColorToJson,
  )
  final CardColor color;
  @JsonKey(
    name: 'number',
    fromJson: cardNumberFromJson,
    toJson: cardNumberToJson,
  )
  final CardNumber number;
  @JsonKey(ignore: true)
  final SpecialRule rule;

  GameCard({this.color, this.number}) : rule = ruleFromNumber(number);

  factory GameCard.fromJson(Map<String, dynamic> json) => _$GameCardFromJson(json);

  Map<String, dynamic> toJson() => _$GameCardToJson(this);

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

  static CardColor cardColorFromJson(String json) => CardColor.values.firstWhere((c) => c.toString() == json);

  static String cardColorToJson(CardColor color) => color.toString();

  static CardNumber cardNumberFromJson(String json) => CardNumber.values.firstWhere((n) => n.toString() == json);

  static String cardNumberToJson(CardNumber number) => number.toString();
}

enum CardColor { heart, diamond, spade, clover }
enum CardNumber { five, six, seven, eight, nine, jack, queen, king, ace, joker }
enum SpecialRule { reverse, skip, joker, plusTwo }
