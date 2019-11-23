import 'package:superbingo/models/app_models/player.dart';

class InformationStorage {
  static final InformationStorage instance = InformationStorage._internal();

  factory InformationStorage() => instance;

  InformationStorage._internal();

  String _gameID, _gameLink;
  int _playerId;
  Player _self;

  String get gameId => _gameID ?? '';
  String get gameLink => _gameLink ?? '';
  int get playerId => _playerId ?? -1;

  set gameId(String value) {
    _gameID = value ?? '';
  }

  set gameLink(String value) {
    _gameLink = value ?? '';
  }

  set playerId(int value) {
    _playerId = value ?? -1;
  }

  void clearInformations() {
    _gameID = '';
    _gameLink = '';
    _playerId = -1;
  }
}
