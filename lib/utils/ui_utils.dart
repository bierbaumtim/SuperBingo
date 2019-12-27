/// Berechnet die Coordinaten eines `PlayerAvatar` auf Basis des `index`, `length` und `playerAvatarBottomPosition`
///
/// `index` - Index des Spielers in der Liste aller Spieler des Spiels
/// `length` - Menge aller Spieler des Spiels
/// `playerAvatarBottomPosition` - maximale Punkt, vom oberen Rand gesehen, an dem ein `PlayerAvatar` positioniert werden kann
Map<String, double> getPositionCoordinates(
  int index,
  int length,
  double playerAvatarBottomPosition,
) {
  double top, left, right, bottom;
  switch (length) {
    case 2:
      if (index == 0) {
        left = 0;
      } else {
        right = 0;
      }
      break;
    case 3:
      if (index < 2) {
        left = 0;
      } else {
        right = 0;
      }

      if (index == 0) bottom = 0;
      break;
    case 4:
      if (index < 2) {
        left = 0;
      } else {
        right = 0;
      }

      if (index == 0 || index == 3) bottom = 0;
      break;
    case 5:
      if (index < 3) {
        left = 0;
      } else {
        right = 0;
      }

      if (index == 0) bottom = 0;
      if (index == 1 || index == 4) {
        top = (playerAvatarBottomPosition / 2) - 32;
      }
      break;
    case 6:
      if (index < 3) {
        left = 0;
      } else {
        right = 0;
      }

      if (index == 0 || index == 5) bottom = 0;
      if (index == 1 || index == 4) {
        top = (playerAvatarBottomPosition / 2) - 32;
      }
      break;
    default:
      left = 0;
      top = 0;
  }

  return {
    'top': top,
    'left': left,
    'right': right,
    'bottom': bottom,
  };
}
