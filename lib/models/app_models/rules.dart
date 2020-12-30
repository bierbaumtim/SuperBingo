import '../../constants/enums.dart';
import 'card.dart';
import 'game.dart';

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
    } else if (card.color == topCard.color || card.number == topCard.number) {
      return true;
    } else if (card.rule == SpecialRule.joker) {
      return true;
    } else {
      return false;
    }
  }

  static String checkRules(Game game, GameCard card, String playerId) {
    if (game.currentPlayerId != playerId) {
      return 'Du bist nicht an der Reihe!';
    }
    if (!game.isJokerOrJackAllowed && card.rule == SpecialRule.joker) {
      return 'Du darfst keine zwei Joker/Buben aufeinander legen!';
    }
    if (game.allowedCardColor != null && game.allowedCardColor != card.color) {
      return 'Der letzte Spieler hat sich eine andere Farbe gewünscht. Du darfst diese Karte daher nicht legen!';
    }
    if (game.allowedCardNumber != null &&
        game.allowedCardNumber != card.number) {
      return 'Du darfst nur ${game.allowedCardNumber.toReadableString(withArticle: true)} legen.';
    }
    if (game.cardDrawAmount > 1 && card.number != CardNumber.seven) {
      return 'Du musst ${game.cardDrawAmount} Karten ziehen!';
    }
    if (!isCardAllowed(card, game.topCard)) {
      return 'Du darfst diese Karte nicht legen!';
    }

    return null;
  }
}
