// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    isHost: json['isHost'] as bool? ?? false,
    finishPosition: json['finishPosition'] as int? ?? 0,
    cards: (json['cards'] as List<dynamic>?)
            ?.map((e) => GameCard.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cards': instance.cards.map((e) => e.toJson()).toList(),
      'isHost': instance.isHost,
      'finishPosition': instance.finishPosition,
    };
