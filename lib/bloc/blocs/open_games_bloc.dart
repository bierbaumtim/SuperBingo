import 'dart:async';

import 'package:rxdart/subjects.dart';

import '../../models/app_models/game.dart';
import '../../services/network_service/network_service_interface.dart';

class PublicGamesBloc {
  final INetworkService networkService;

  StreamSubscription _gamesSub;

  PublicGamesBloc(this.networkService) {
    _publicGamesController = BehaviorSubject<List<Game>>();
    initListener();
  }

  BehaviorSubject<List<Game>> _publicGamesController;

  Sink get _publicGamesSink => _publicGamesController.sink;
  Stream<List<Game>> get publicGamesStream => _publicGamesController.stream;

  Future<void> getPublicGames() async {
    _publicGamesSink.add(null);
    final games = await networkService.getPublicGames();
    _publicGamesController.sink.add(games);
  }

  void initListener() {
    getPublicGames().then((_) {
      _gamesSub = networkService.publicGamesStream.skip(1).listen((value) {
        if (value is Error) {
          _publicGamesController.sink.addError(value);
        } else {
          _publicGamesController.sink.add(value);
        }
      });
    });
  }

  void dispose() {
    _publicGamesController?.close();
    _gamesSub?.cancel();
  }
}
