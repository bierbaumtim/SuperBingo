// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player(
    id: json['id'] as String ?? '',
    name: json['name'] as String ?? '',
    cards: (json['cards'] as List)
            ?.map((e) =>
                e == null ? null : GameCard.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
    isHost: json['isHost'] as bool ?? false,
  );
}

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cards': instance.cards,
      'isHost': instance.isHost,
    };
