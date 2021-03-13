// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameCard _$GameCardFromJson(Map<String, dynamic> json) {
  return GameCard(
    id: json['id'] as String,
    color: _$enumDecode(_$CardColorEnumMap, json['color']),
    number: _$enumDecode(_$CardNumberEnumMap, json['number']),
  );
}

Map<String, dynamic> _$GameCardToJson(GameCard instance) => <String, dynamic>{
      'id': instance.id,
      'color': _$CardColorEnumMap[instance.color],
      'number': _$CardNumberEnumMap[instance.number],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$CardColorEnumMap = {
  CardColor.heart: 'heart',
  CardColor.diamond: 'diamond',
  CardColor.spade: 'spade',
  CardColor.clover: 'clover',
};

const _$CardNumberEnumMap = {
  CardNumber.five: 'five',
  CardNumber.six: 'six',
  CardNumber.seven: 'seven',
  CardNumber.eight: 'eight',
  CardNumber.nine: 'nine',
  CardNumber.jack: 'jack',
  CardNumber.queen: 'queen',
  CardNumber.king: 'king',
  CardNumber.ace: 'ace',
  CardNumber.joker: 'joker',
};
