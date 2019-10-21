// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) {
  return Game(
    gameID: json['id'] as String ?? '',
    playedCardStack: Game.stackFromJson(json['playedCards'] as List),
    unplayedCardStack: Game.stackFromJson(json['unplayedCards'] as List),
    players: (json['players'] as List)
        ?.map((e) =>
            e == null ? null : Player.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    name: json['name'] as String ?? 'SuperBingo',
    maxPlayer: json['maxPlayer'] as int ?? 6,
    isPublic: json['isPublic'] as bool ?? true,
    cardAmount: json['cardAmount'] as int ?? 32,
    currentPlayerId: json['currentPlayerId'] as int ?? '',
    state: _$enumDecodeNullable(_$GameStateEnumMap, json['state']) ??
        GameState.waitingForPlayer,
  );
}

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'playedCards': Game.stackToJson(instance.playedCardStack),
      'unplayedCards': Game.stackToJson(instance.unplayedCardStack),
      'players': instance.players,
      'isPublic': instance.isPublic,
      'maxPlayer': instance.maxPlayer,
      'cardAmount': instance.cardAmount,
      'name': instance.name,
      'id': instance.gameID,
      'currentPlayerId': instance.currentPlayerId,
      'state': _$GameStateEnumMap[instance.state],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$GameStateEnumMap = {
  GameState.waitingForPlayer: 'waitingForPlayer',
  GameState.active: 'active',
  GameState.gameCompleted: 'gameCompleted',
};
