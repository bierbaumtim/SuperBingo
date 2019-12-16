import 'package:equatable/equatable.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';

abstract class CurrentGameEvent extends Equatable {
  const CurrentGameEvent();

  @override
  List<Object> get props => [];
}

/// Event, dass startet das Spiel mit der `gameId`
class StartGame extends CurrentGameEvent {
  final String gameId;
  final Player self;

  const StartGame({this.gameId, this.self});

  @override
  List<Object> get props => super.props..addAll([gameId, self]);
}

class StartGameWaitingLobby extends CurrentGameEvent {
  final String gameId;
  final Player self;

  const StartGameWaitingLobby({
    this.gameId,
    this.self,
  });

  @override
  List<Object> get props => super.props..addAll([gameId, self]);
}

class LeaveGame extends CurrentGameEvent {}

class EndGame extends CurrentGameEvent {}

class UpdateCurrentGame extends CurrentGameEvent {
  final Game game;

  const UpdateCurrentGame(this.game);

  @override
  List<Object> get props => super.props..add(game);
}

class PlayCard extends CurrentGameEvent {
  final GameCard card;

  const PlayCard(this.card);

  @override
  List<Object> get props => super.props..add(card);
}
