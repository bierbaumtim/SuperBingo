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
            ?.toList() ??
        [],
    name: json['name'] as String ?? 'SuperBingo',
    maxPlayer: json['maxPlayer'] as int ?? 6,
    isPublic: json['isPublic'] as bool ?? true,
    cardAmount: json['cardAmount'] as int ?? 32,
    isGameRunning: json['isGameRunning'] as bool ?? false,
  );
}

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'playedCards': Game.stackToJson(instance.playedCardStack),
      'unplayedCards': Game.stackToJson(instance.unplayedCardStack),
      'players': instance.players,
      'isGameRunning': instance.isGameRunning,
      'isPublic': instance.isPublic,
      'maxPlayer': instance.maxPlayer,
      'cardAmount': instance.cardAmount,
      'name': instance.name,
      'id': instance.gameID,
    };
