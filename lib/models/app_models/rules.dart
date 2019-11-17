import 'package:superbingo/models/app_models/card.dart';

/// {@template rules}
/// Singleton
///
/// Stellt Methoden bereit die die Regeln des Spiels abdecken.
/// {@endtemplate}
class Rules {
  /// {@macro rules}
  static final Rules instance = Rules._internal();

  /// {@macro rules}
  factory Rules() => instance;

  Rules._internal();

  /// Prüft ob die `card` auf die `topCard` gelegt werden darf.
  static bool isCardAllowed(GameCard card, GameCard topCard) {
    if (topCard == null) {
      return true;
    } else if ((card.color == topCard.color || card.number == topCard.number)) {
      return true;
    } else {
      return false;
    }
  }
}
