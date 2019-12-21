import 'package:superbingo/models/app_models/player.dart';

class InformationStorage {
  static final InformationStorage instance = InformationStorage._internal();

  factory InformationStorage() => instance;

  InformationStorage._internal();

  String _gameID, _gameLink, _playerId;
  Player _self;

  String get gameId => _gameID ?? '';
  String get gameLink => _gameLink ?? '';
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

  void clearInformations() {
    _gameID = '';
    _gameLink = '';
    // _playerId = '';
  }
}
