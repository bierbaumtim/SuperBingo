/// Singelton um wichtige Informationen, über mehrere Klassen einfach verfügbar zu haben.
class InformationStorage {
  /// Singleton instance
  static final InformationStorage instance = InformationStorage._internal();

  /// Factory Costructor, der auf die Singleton Instanz verweist
  factory InformationStorage() => instance;

  InformationStorage._internal();

  String _gameID, _gameLink, _playerId;

  /// Firestore Document ID die auf ein bestimmtes Spiel in der DB verweist
  String get gameId => _gameID ?? '';

  /// Link, mit dem ein bestimmtes Spiel aus der DB abgerufen werden kann
  String get gameLink => _gameLink ?? '';

  /// UID des Client-abhängigen Spielers
  String get playerId => _playerId ?? '';

  set gameId(String value) {
    _gameID = value ?? '';
  }

  set gameLink(String value) {
    _gameLink = value ?? '';
  }

  set playerId(String value) {
    _playerId = value ?? '';
  }

  /// Setzt die gespeicherten Werte zurück
  void clearInformations() {
    _gameID = '';
    _gameLink = '';
    // _playerId = '';
  }
}
