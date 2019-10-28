import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'card.g.dart';

@JsonSerializable()
class GameCard extends Equatable {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'color')
  final CardColor color;
  @JsonKey(name: 'number')
  final CardNumber number;
  @JsonKey(ignore: true)
  final SpecialRule rule;

  GameCard({this.id, this.color, this.number}) : rule = ruleFromNumber(number);

  factory GameCard.fromJson(Map<String, dynamic> json) =>
      _$GameCardFromJson(json);

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

  GameCard setId(int id) => GameCard(
        id: id,
        color: this.color,
        number: this.number,
      );

  @override
  List<Object> get props => [rule, color, number, id];

  // static CardColor cardColorFromJson(String json) => CardColor.values.firstWhere((c) => c.toString() == json);

  // static String cardColorToJson(CardColor color) => color.toString();

  // static CardNumber cardNumberFromJson(String json) => CardNumber.values.firstWhere((n) => n.toString() == json);

  // static String cardNumberToJson(CardNumber number) => number.toString();
}

enum CardColor { heart, diamond, spade, clover }
enum CardNumber { five, six, seven, eight, nine, jack, queen, king, ace, joker }
enum SpecialRule { reverse, skip, joker, plusTwo }
