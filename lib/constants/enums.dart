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
