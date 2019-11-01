import 'package:equatable/equatable.dart';

abstract class JoinGameState extends Equatable {
  const JoinGameState();

  @override
  List<Object> get props => [];
}

class JoiningGame extends JoinGameState {}

class JoinedGame extends JoinGameState {
  final String gameId;

  JoinedGame(this.gameId);
}

class JoinGameFailed extends JoinGameState {
  final String error;

  const JoinGameFailed(this.error);

  @override
  List<Object> get props => super.props..add(error);
}

class WaitingForAction extends JoinGameState {}
