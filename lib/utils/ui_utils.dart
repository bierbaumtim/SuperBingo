import 'package:flutter/rendering.dart';

import '../constants/ui_constants.dart';
import '../models/ui_models/player_avatar_coordinates.dart';

/// Berechnet die Coordinaten eines `PlayerAvatar` auf Basis des `index`, `length` und `playerAvatarBottomPosition`
///
/// `index` - Index des Spielers in der Liste aller Spieler des Spiels
/// `length` - Menge aller Spieler des Spiels
/// `constraints` - Grenzen in den sich die Avatare befinden müssen. Sind identisch zum "Tisch".
PlayerAvatarCoordinates getPositionCoordinates(
  int index,
  int length,
  BoxConstraints constraints,
) {
  if (constraints.maxHeight >= constraints.maxWidth) {
    return _getVerticalPositionCoordinates(
      index,
      length,
      constraints,
    );
  } else {
    return _getHorizontalPositionCoordinates(
      index,
      length,
      constraints,
    );
  }
}

PlayerAvatarCoordinates _getVerticalPositionCoordinates(
  int index,
  int length,
  BoxConstraints constraints,
) {
  switch (index) {
    case 0:
      return positionVerticalTopCenter(constraints);
    case 1:
      if (length == 2) {
        return positionVerticalBottomCenter(constraints);
      } else if (length == 3 || length == 4) {
        return positionVerticalRightCenter(constraints);
      } else {
        return positionVerticalRightTop(constraints);
      }
    case 2:
      if (length == 3 || length == 4) {
        return positionVerticalBottomCenter(constraints);
      } else if (length == 5 || length == 6) {
        return positionVerticalRightBottom(constraints);
      } else {
        return positionVerticalRightCenter(constraints);
      }
    case 3:
      if (length == 4) {
        return positionVerticalLeftCenter(constraints);
      } else if (length == 5 || length == 6) {
        return positionVerticalBottomCenter(constraints);
      } else {
        return positionVerticalRightBottom(constraints);
      }
    case 4:
      if (length == 5) {
        return positionVerticalLeftCenter(constraints);
      } else if (length == 6) {
        return positionVerticalLeftBottom(constraints);
      } else {
        return positionVerticalBottomCenter(constraints);
      }
    case 5:
      if (length == 6) {
        return positionVerticalLeftTop(constraints);
      } else {
        return positionVerticalLeftBottom(constraints);
      }
    case 6:
      if (length == 7) {
        return positionVerticalLeftTop(constraints);
      } else {
        return positionVerticalLeftCenter(constraints);
      }
    case 7:
      return positionVerticalLeftTop(constraints);
    default:
      return defaultPlayerAvatarCoordinates;
  }
}

PlayerAvatarCoordinates _getHorizontalPositionCoordinates(
  int index,
  int length,
  BoxConstraints constraints,
) {
  switch (index) {
    case 0:
      return positionHorizontalLeftCenter(constraints);
    case 1:
      if (length == 2) {
        return positionHorizontalRightCenter(constraints);
      } else if (length == 3 || length == 4) {
        return positionHorizontalTopCenter(constraints);
      } else {
        return positionHorizontalTopLeft(constraints);
      }
    case 2:
      if (length == 3 || length == 4) {
        return positionHorizontalRightCenter(constraints);
      } else if (length == 5 || length == 6) {
        return positionHorizontalTopRight(constraints);
      } else {
        return positionHorizontalTopCenter(constraints);
      }
    case 3:
      if (length >= 4 && length <= 6) {
        return positionHorizontalBottomCenter(constraints);
      } else {
        return positionHorizontalTopRight(constraints);
      }
    case 4:
      if (length == 5) {
        return positionHorizontalBottomCenter(constraints);
      } else if (length == 6) {
        return positionHorizontalBottomRight(constraints);
      } else {
        return positionHorizontalRightCenter(constraints);
      }
    case 5:
      if (length == 6) {
        return positionHorizontalBottomLeft(constraints);
      } else {
        return positionHorizontalBottomRight(constraints);
      }
    case 6:
      if (length == 7) {
        return positionHorizontalBottomLeft(constraints);
      } else {
        return positionHorizontalBottomCenter(constraints);
      }
    case 7:
      return positionHorizontalBottomLeft(constraints);
    default:
      return defaultPlayerAvatarCoordinates;
  }
}

const defaultPlayerAvatarCoordinates = PlayerAvatarCoordinates(
  left: 0,
  top: 0,
  right: null,
  bottom: null,
  horizontalTranslation: 0,
  verticalTranslation: 0,
);

/// ========== Horizontal Positions ==========

PlayerAvatarCoordinates positionHorizontalLeftCenter(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      top: constraints.maxHeight / 2,
      bottom: null,
      left: 0,
      right: null,
      horizontalTranslation: -0.5,
      verticalTranslation: -0.5,
    );

PlayerAvatarCoordinates positionHorizontalRightCenter(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      top: constraints.maxHeight / 2,
      bottom: null,
      left: null,
      right: 0,
      horizontalTranslation: 0.5,
      verticalTranslation: -0.5,
    );

PlayerAvatarCoordinates positionHorizontalTopLeft(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      top: 0,
      bottom: null,
      left: (constraints.maxWidth -
              (constraints.maxWidth * kTableInnerSizeFactor)) /
          2,
      right: null,
      horizontalTranslation: 0.1,
      verticalTranslation: -0.35,
    );

PlayerAvatarCoordinates positionHorizontalTopRight(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      top: 0,
      bottom: null,
      left: null,
      right: (constraints.maxWidth -
              (constraints.maxWidth * kTableInnerSizeFactor)) /
          2,
      horizontalTranslation: -0.1,
      verticalTranslation: -0.35,
    );

PlayerAvatarCoordinates positionHorizontalTopCenter(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      top: 0,
      bottom: null,
      left: constraints.maxWidth / 2,
      right: null,
      horizontalTranslation: -0.5,
      verticalTranslation: -0.35,
    );

PlayerAvatarCoordinates positionHorizontalBottomCenter(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      top: null,
      bottom: 0,
      left: constraints.maxWidth / 2,
      right: null,
      horizontalTranslation: -0.5,
      verticalTranslation: 0.65,
    );

PlayerAvatarCoordinates positionHorizontalBottomLeft(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      top: null,
      bottom: 0,
      left: (constraints.maxWidth -
              (constraints.maxWidth * kTableInnerSizeFactor)) /
          2,
      right: null,
      horizontalTranslation: 0.1,
      verticalTranslation: 0.65,
    );

PlayerAvatarCoordinates positionHorizontalBottomRight(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      top: null,
      bottom: 0,
      left: null,
      right: (constraints.maxWidth -
              (constraints.maxWidth * kTableInnerSizeFactor)) /
          2,
      horizontalTranslation: 0.1,
      verticalTranslation: 0.65,
    );

/// ========== Vertical Positions ==========

PlayerAvatarCoordinates positionVerticalTopCenter(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      left: constraints.maxWidth / 2,
      right: null,
      top: 0,
      bottom: null,
      verticalTranslation: -0.35,
      horizontalTranslation: -0.5,
    );

PlayerAvatarCoordinates positionVerticalRightTop(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      left: null,
      right: 0,
      top: (constraints.maxHeight -
              (constraints.maxHeight * kTableInnerSizeFactor)) /
          2,
      bottom: null,
      verticalTranslation: -0.1,
      horizontalTranslation: 0.5,
    );

PlayerAvatarCoordinates positionVerticalRightCenter(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      left: null,
      right: 0,
      top: constraints.maxHeight / 2,
      bottom: null,
      verticalTranslation: -0.5,
      horizontalTranslation: 0.5,
    );

PlayerAvatarCoordinates positionVerticalRightBottom(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      left: null,
      right: 0,
      top: null,
      bottom: (constraints.maxHeight -
              (constraints.maxHeight * kTableInnerSizeFactor)) /
          2,
      verticalTranslation: 0.1,
      horizontalTranslation: 0.5,
    );

PlayerAvatarCoordinates positionVerticalBottomCenter(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      left: constraints.maxWidth / 2,
      right: null,
      top: null,
      bottom: 0,
      verticalTranslation: 0.65,
      horizontalTranslation: -0.5,
    );

PlayerAvatarCoordinates positionVerticalLeftTop(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      left: 0,
      right: null,
      top: (constraints.maxHeight -
              (constraints.maxHeight * kTableInnerSizeFactor)) /
          2,
      bottom: null,
      verticalTranslation: -0.1,
      horizontalTranslation: -0.5,
    );

PlayerAvatarCoordinates positionVerticalLeftCenter(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      left: 0,
      right: null,
      top: constraints.maxHeight / 2,
      bottom: null,
      verticalTranslation: -0.5,
      horizontalTranslation: -0.5,
    );

PlayerAvatarCoordinates positionVerticalLeftBottom(
  BoxConstraints constraints,
) =>
    PlayerAvatarCoordinates(
      left: 0,
      right: null,
      top: null,
      bottom: (constraints.maxHeight -
              (constraints.maxHeight * kTableInnerSizeFactor)) /
          2,
      verticalTranslation: 0.1,
      horizontalTranslation: -0.5,
    );
