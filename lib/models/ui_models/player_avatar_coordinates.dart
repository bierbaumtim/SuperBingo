import 'package:flutter/foundation.dart';

class PlayerAvatarCoordinates {
  final double top;
  final double left;
  final double right;
  final double bottom;
  final double verticalTranslation;
  final double horizontalTranslation;

  const PlayerAvatarCoordinates({
    @required this.top,
    @required this.left,
    @required this.right,
    @required this.bottom,
    @required this.verticalTranslation,
    @required this.horizontalTranslation,
  });
}
