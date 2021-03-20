// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) {
  return Game(
    gameID: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'SuperBingo',
    playedCardStack: Game.stackFromJson(json['playedCards'] as List?),
    unplayedCardStack: Game.stackFromJson(json['unplayedCards'] as List?),
    players: (json['players'] as List<dynamic>?)
            ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    maxPlayer: json['maxPlayer'] as int? ?? 6,
    isPublic: json['isPublic'] as bool? ?? true,
    cardAmount: json['cardAmount'] as int? ?? 32,
    currentPlayerId: json['currentPlayerId'] as String? ?? '',
    cardDrawAmount: json['cardDrawAmount'] as int? ?? 1,
    allowedCardColor:
        _$enumDecodeNullable(_$CardColorEnumMap, json['allowedCardColor']),
    isJokerOrJackAllowed: json['isJokerOrJackAllowed'] as bool? ?? true,
    state: _$enumDecodeNullable(_$GameStateEnumMap, json['state']) ??
        GameState.waitingForPlayer,
    message: json['message'] as String? ?? '',
    allowedCardNumber:
        _$enumDecodeNullable(_$CardNumberEnumMap, json['allowedCardNumber']),
    playerOrder: (json['playerOrder'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'playedCards': Game.stackToJson(instance.playedCardStack),
      'unplayedCards': Game.stackToJson(instance.unplayedCardStack),
      'players': instance.players.map((e) => e.toJson()).toList(),
      'isPublic': instance.isPublic,
      'maxPlayer': instance.maxPlayer,
      'cardAmount': instance.cardAmount,
      'cardDrawAmount': instance.cardDrawAmount,
      'name': instance.name,
      'id': instance.gameID,
      'currentPlayerId': instance.currentPlayerId,
      'state': _$GameStateEnumMap[instance.state],
      'allowedCardColor': _$CardColorEnumMap[instance.allowedCardColor],
      'allowedCardNumber': _$CardNumberEnumMap[instance.allowedCardNumber],
      'isJokerOrJackAllowed': instance.isJokerOrJackAllowed,
      'message': instance.message,
      'playerOrder': instance.playerOrder,
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

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$CardColorEnumMap = {
  CardColor.heart: 'heart',
  CardColor.diamond: 'diamond',
  CardColor.spade: 'spade',
  CardColor.clover: 'clover',
};

const _$GameStateEnumMap = {
  GameState.created: 'created',
  GameState.waitingForPlayer: 'waitingForPlayer',
  GameState.active: 'active',
  GameState.gameCompleted: 'gameCompleted',
  GameState.finished: 'finished',
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
