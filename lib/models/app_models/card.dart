import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../constants/enums.dart';

part 'card.g.dart';

/// {@template gamecard}
/// Datenhaltungsklasse für eine Spielkarte
/// {@endtemplate}
@JsonSerializable(explicitToJson: true)
class GameCard extends Equatable {
  /// ID der Karte.
  ///
  /// Einzigartig pro Spiel
  @JsonKey(name: 'id')
  final String id;

  /// Farbe der Karte
  @JsonKey(name: 'color')
  final CardColor color;

  /// Number der Karte.
  ///
  /// Wichtig für die Regeln
  @JsonKey(name: 'number')
  final CardNumber number;

  /// Kartenabhängige Regel
  @JsonKey(ignore: true)
  final SpecialRule rule;

  /// {@macro gamecard}
  GameCard({
    this.id,
    @required this.color,
    @required this.number,
  }) : rule = ruleFromNumber(number);

  /// Factory, um einen Datensatz in ein [GameCard]-Object umzuwandeln
  factory GameCard.fromJson(Map<String, dynamic> json) =>
      _$GameCardFromJson(json);

  /// Wandelt ein [GameCard]-Object in eine Datenbank-kompatible Map um
  Map<String, dynamic> toJson() => _$GameCardToJson(this);

  /// Ermittelt die Regel der Karte auf Basis der [CardNumber] `number`
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

  /// Gibt ein neues [GameCard]-Object zurück, mit der `id`
  /// und den anderen Attributen des aktuellen Objects
  GameCard setId(String id) => GameCard(
        id: id,
        color: color,
        number: number,
      );

  @override
  List<Object> get props => <Object>[rule, color, number, id];

  @override
  bool get stringify => true;
}
