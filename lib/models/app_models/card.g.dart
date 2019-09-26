// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameCard _$GameCardFromJson(Map<String, dynamic> json) {
  return GameCard(
    color: GameCard.cardColorFromJson(json['color'] as String),
    number: GameCard.cardNumberFromJson(json['number'] as String),
  );
}

Map<String, dynamic> _$GameCardToJson(GameCard instance) => <String, dynamic>{
      'color': GameCard.cardColorToJson(instance.color),
      'number': GameCard.cardNumberToJson(instance.number),
    };
