import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/enums.dart';
import 'list_utils.dart';

/// Gibt das zur `color` gehörende Icon zurück.
IconData getIconByCardColor(CardColor color) {
  switch (color) {
    case CardColor.clover:
      return CupertinoIcons.suit_club_fill;
    case CardColor.heart:
      return CupertinoIcons.suit_heart_fill;
    case CardColor.diamond:
      return CupertinoIcons.suit_diamond_fill;
    case CardColor.spade:
      return CupertinoIcons.suit_spade_fill;
    default:
      return Icons.error;
  }
}

/// Gibt die zur `color` gehörende Farbe zurück.
Color getColorByCardColor(CardColor color) {
  if (color == CardColor.heart || color == CardColor.diamond) {
    return Colors.red;
  } else {
    return Colors.black;
  }
}

/// Gibt die Nummer/den Buchstaben zur `number` zugehörigen zurück.
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

/// Abfrage ob die `number` eine Nummer ist.
bool isNumberCard(CardNumber number) =>
    number == CardNumber.five ||
    number == CardNumber.six ||
    number == CardNumber.seven ||
    number == CardNumber.eight ||
    number == CardNumber.nine;

Map<String, double> getRotationAngles(int index, int length) {
  var angle = 160 / length;
  double rotationAngle;
  if (angle >= 50) angle = 20;
  final middle = getMiddleIndex(List<String>.generate(length, (_) => ''));

  if (index >= middle || index <= middle) {
    angle = -90 - (angle * (middle - index));
    rotationAngle = 270 + angle;
  } else {
    angle = -90;
    rotationAngle = 0;
  }

  return {
    'angle': angle,
    'rotation': rotationAngle,
  };
}
