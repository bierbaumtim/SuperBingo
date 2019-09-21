import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart';

import 'package:community_material_icon/community_material_icon.dart';

IconData getIconByCardColor(CardColor color) {
  assert(color != null);

  switch (color) {
    case CardColor.clover:
      return CommunityMaterialIcons.cards_club;
    case CardColor.heart:
      return CommunityMaterialIcons.cards_heart;
    case CardColor.diamond:
      return CommunityMaterialIcons.cards_diamond;
    case CardColor.spade:
      return CommunityMaterialIcons.cards_spade;
    default:
      return Icons.error;
  }
}

Color getColorByCardColor(CardColor color) {
  assert(color != null);

  if (color == CardColor.heart || color == CardColor.diamond) {
    return Colors.red;
  } else {
    return Colors.black;
  }
}

String getTextByCardNumber(CardNumber number) {
  switch (number) {
    case CardNumber.ace:
      return 'A';
    case CardNumber.king:
      return 'K';
    case CardNumber.queen:
      return 'D';
    case CardNumber.jack:
      return 'B';
    case CardNumber.joker:
      return 'J';
    case CardNumber.nine:
      return '9';
    case CardNumber.eight:
      return '8';
    case CardNumber.seven:
      return '7';
    case CardNumber.six:
      return '6';
    case CardNumber.five:
      return '5';
    default:
      return '';
  }
}
