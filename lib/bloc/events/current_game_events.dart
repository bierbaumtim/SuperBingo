import 'package:equatable/equatable.dart';

abstract class CurrentGameEvent extends Equatable {
  const CurrentGameEvent();

  @override
  List<Object> get props => [];
}

/// Event, dass startet das Spiel mit der `gameId`
class StartGame extends CurrentGameEvent {
  final String gameId;

  const StartGame(this.gameId);

  @override
  List<Object> get props => super.props..add(gameId);
}

class StartGameWaitingLobby extends CurrentGameEvent {
  final String gameId;

  const StartGameWaitingLobby(this.gameId);

  @override
  List<Object> get props => super.props..add(gameId);
}

class LeaveGame extends CurrentGameEvent {}

class EndGame extends CurrentGameEvent {}
