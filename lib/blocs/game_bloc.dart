import 'package:rxdart/rxdart.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/player.dart';

class GameBloc {
  GameBloc() {
    _playerController = BehaviorSubject<List<Player>>();
    _cardController = BehaviorSubject<List<GameCard>>();
    _handCardController = BehaviorSubject<List<GameCard>>();
  }

  void dispose() {
    _playerController.close();
    _cardController.close();
    _handCardController.close();
  }

  BehaviorSubject<List<Player>> _playerController;
  Sink get _playerSink => _playerController.sink;
  Stream get playerStream => _playerController.stream;

  BehaviorSubject<List<GameCard>> _cardController;
  Sink get _cardSink => _cardController.sink;
  Stream get cardStream => _cardController.stream;

  BehaviorSubject<List<GameCard>> _handCardController;
  Sink get _handCardSink => _handCardController.sink;
  Stream get handCardStream => _handCardController.stream;
}
