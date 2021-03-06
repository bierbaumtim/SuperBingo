/// States um abhängig davon eine Meldung an den Nutzer auszugeben
enum JoiningState {
  /// Spieler ist dem Spiel erfolgreich beigetreten
  success,

  /// Spiel-Datensatz ist beschädigt
  dataIssue,

  /// Spieler ist diesem Spiel schon einmal beigetreten
  playerAlreadyJoined,

  /// Spieler konnte dem Spiel aufgrund eines Fehlers nicht beitreten
  error
}

/// Die verschiedenen Farben der Karten
enum CardColor {
  /// Herz
  heart,

  /// Karo
  diamond,

  /// Pik
  spade,

  /// Kreuz
  clover
}

/// Die verschiedenen Nummern/Symbole der Karten
enum CardNumber {
  /// 5
  five,

  /// 6
  six,

  /// 7
  seven,

  ///8
  eight,

  /// 9
  nine,

  /// Bube
  jack,

  /// Dame
  queen,

  /// König
  king,

  /// Ass
  ace,

  /// Joker
  joker
}

/// Regeln des Spiels
enum SpecialRule {
  /// Spielreihenfolge wird umgedreht
  reverse,

  /// nächste Spieler wird übersprungen
  skip,

  /// Karten kann auf jeden Karten gelegt werden. Kann als Wünschen-Karte genutzt werden
  joker,

  /// nächste Spieler muss 2 Karten ziehen
  plusTwo
}

extension CardColorX on CardColor {
  String toReadableString() {
    switch (this) {
      case CardColor.clover:
        return 'Kreuz';
      case CardColor.diamond:
        return 'Karo';
      case CardColor.heart:
        return 'Herz';
      case CardColor.spade:
        return 'Pik';
      default:
        return '';
    }
  }

  int get comparableValue {
    switch (this) {
      case CardColor.clover:
        return 4;
      // Pik
      case CardColor.spade:
        return 3;
      // Herz
      case CardColor.heart:
        return 1;
      // Karo
      case CardColor.diamond:
      default:
        return 0;
    }
  }

  int compareTo(CardColor other) {
    return other.comparableValue - comparableValue;
  }
}

extension CardNumberX on CardNumber {
  String toReadableString({bool withArticle = false}) {
    switch (this) {
      case CardNumber.ace:
        return '${withArticle ? 'ein ' : ''}Ass';
      case CardNumber.king:
        return '${withArticle ? 'einen ' : ''}König';
      case CardNumber.queen:
        return '${withArticle ? 'eine ' : ''}Dame';
      case CardNumber.jack:
        return '${withArticle ? 'einen ' : ''}Bube';
      case CardNumber.joker:
        return '${withArticle ? 'einen ' : ''}Joker';
      case CardNumber.nine:
        return '${withArticle ? 'eine ' : ''}9';
      case CardNumber.eight:
        return '${withArticle ? 'eine ' : ''}8';
      case CardNumber.seven:
        return '${withArticle ? 'eine ' : ''}7';
      case CardNumber.six:
        return '${withArticle ? 'eine ' : ''}6';
      case CardNumber.five:
        return '${withArticle ? 'eine ' : ''}5';
      default:
        return '';
    }
  }

  int get comparableValue {
    switch (this) {
      case CardNumber.joker:
        return 14;
      case CardNumber.ace:
        return 13;
      case CardNumber.king:
        return 12;
      case CardNumber.queen:
        return 11;
      case CardNumber.jack:
        return 10;
      case CardNumber.nine:
        return 9;
      case CardNumber.eight:
        return 8;
      case CardNumber.seven:
        return 7;
      case CardNumber.six:
        return 6;
      case CardNumber.five:
        return 5;
      default:
        return 0;
    }
  }

  int compareTo(CardNumber other) {
    return other.comparableValue - comparableValue;
  }
}
